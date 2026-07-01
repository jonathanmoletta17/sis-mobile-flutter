#!/usr/bin/env bash
# Levantamento de cobertura GLPI SIS (read-only). Bate itemtypes de Administração/
# Configuração na instância real e salva evidência. Não imprime credenciais/token.
set -uo pipefail
cd /home/jonathan/projects/work/mobile/sis-mobile-flutter
while IFS='=' read -r key val; do
  [[ "$key" =~ ^[A-Za-z_][A-Za-z0-9_]*$ ]] || continue
  val="${val%$'\r'}"; export "$key=$val"
done < .env

BASE="${SIS_TEST_BASE_URL%/}"
APP="${GLPI_APP_TOKEN:-}"
OUT="docs/discovery/glpi-live"
EVID="$OUT/evidence"
mkdir -p "$EVID"
CSV="$OUT/coverage.csv"
echo "itemtype,http_status,total_count,note" > "$CSV"

# --- auth com a conta ADMIN de teste (read-only; vê config de Administração) ---
auth() {
  local u="$1" p="$2"
  curl -s -m 25 "$BASE/initSession" -H "App-Token: $APP" -u "$u:$p" \
    | grep -oE '"session_token"[[:space:]]*:[[:space:]]*"[^"]+"' \
    | grep -oE '[A-Za-z0-9]{15,}' | head -1
}
TOKEN=$(auth "$SIS_TEST_ADMIN_USER" "$SIS_TEST_ADMIN_PASSWORD")
[ -z "$TOKEN" ] && { echo "FALHA auth admin"; exit 1; }
echo "Auth admin OK (token não exibido)."

# Troca o perfil ativo para Super-Admin (id 4) — permitido pelo CLAUDE.md (conta de teste,
# perfil atribuído a ela, reversível via killSession). Sem isso a sessão entra no perfil
# padrao (id 11, tecnico) e leva ERROR_RIGHT_MISSING na config de Administracao.
SUPERADMIN_ID="${SUPERADMIN_PROFILE_ID:-4}"
curl -s -m 20 -X POST "$BASE/changeActiveProfile" \
  -H "App-Token: $APP" -H "Session-Token: $TOKEN" -H "Content-Type: application/json" \
  -d "{\"profiles_id\": $SUPERADMIN_ID}" >/dev/null 2>&1 || true
ACTIVE=$(curl -s -m 20 "$BASE/getActiveProfile" -H "App-Token: $APP" -H "Session-Token: $TOKEN" \
  | grep -oE '"id"[[:space:]]*:[[:space:]]*"?[0-9]+"?' | head -1 | grep -oE '[0-9]+')
echo "Perfil ativo agora: id ${ACTIVE:-?} (esperado $SUPERADMIN_ID = Super-Admin)."

probe() {  # $1 = itemtype (pode incluir query); $2 = nome-arquivo
  local it="$1" name="$2"
  local url="$BASE/$it"
  case "$it" in *\?*) url="$url&range=0-0";; *) url="$url?range=0-0";; esac
  local hdr; hdr=$(curl -s -m 25 -D - -o "$EVID/$name.json" \
    -H "App-Token: $APP" -H "Session-Token: $TOKEN" "$url")
  local code; code=$(printf '%s' "$hdr" | grep -oiE 'HTTP/[0-9.]+ [0-9]+' | tail -1 | grep -oE '[0-9]+$')
  local range; range=$(printf '%s' "$hdr" | grep -oiE 'Content-Range: [^[:space:]]+' | grep -oE '/[0-9]+' | tr -d '/')
  [ -z "${code:-}" ] && code="000"
  [ -z "${range:-}" ] && range="-"
  local note=""
  [ "$code" = "200" ] && note="ok" || note="$(head -c 120 "$EVID/$name.json" 2>/dev/null | tr -d '\n' | sed -E 's/[A-Za-z0-9]{25,}/REDACTED/g')"
  echo "$it,$code,$range,\"$note\"" >> "$CSV"
  printf '  %-45s %s  total=%s\n' "$it" "$code" "$range"
}

echo "== Sessão / derivados =="
for ep in getFullSession getActiveProfile getMyProfiles getActiveEntities getMyEntities getGlpiConfig; do
  probe "$ep" "session_$ep"
done

echo "== Administração: Perfis & Rights =="
for it in Profile ProfileRight Profile_User; do probe "$it" "$it"; done

echo "== Administração: Usuários / Grupos / Entidades =="
for it in User Group Group_User Entity; do probe "$it" "$it"; done

echo "== Administração: Regras =="
for it in Rule RuleCriteria RuleAction; do probe "$it" "$it"; done

echo "== Configuração: Categorias / Dropdowns / Estados =="
for it in ITILCategory TaskCategory RequestType SolutionType State Location Calendar Holiday Manufacturer; do probe "$it" "$it"; done

echo "== Configuração: Templates de Ticket =="
for it in TicketTemplate TicketTemplateMandatoryField TicketTemplatePredefinedField TicketTemplateHiddenField; do probe "$it" "$it"; done

echo "== Configuração: SLA/OLA, Notificações, Cron, Documentos =="
for it in SLM SLA OLA Notification NotificationTemplate CronTask Document DocumentType Link DisplayPreference; do probe "$it" "$it"; done

echo "== Plugin FormCreator =="
for it in PluginFormcreatorForm PluginFormcreatorSection PluginFormcreatorQuestion PluginFormcreatorCondition PluginFormcreatorTargetTicket PluginFormcreatorForm_Profile PluginFormcreatorCategory; do probe "$it" "$it"; done

curl -s -m 15 "$BASE/killSession" -H "App-Token: $APP" -H "Session-Token: $TOKEN" >/dev/null 2>&1 || true
echo "== Coleta concluída. CSV: $CSV =="
echo "Resumo por status:"; tail -n +2 "$CSV" | cut -d, -f2 | sort | uniq -c
