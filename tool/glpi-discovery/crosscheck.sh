#!/usr/bin/env bash
# Cross-check: deriva itemtype de TODAS as 390 tabelas do schema e bate na API real
# (read-only, Super-Admin). Acha domínios fora da lista curada. Não imprime credenciais.
set -uo pipefail
cd /home/jonathan/projects/work/mobile/sis-mobile-flutter
while IFS='=' read -r key val; do
  [[ "$key" =~ ^[A-Za-z_][A-Za-z0-9_]*$ ]] || continue
  val="${val%$'\r'}"; export "$key=$val"
done < .env
BASE="${SIS_TEST_BASE_URL%/}"; APP="${GLPI_APP_TOKEN:-}"
TABLES="/home/jonathan/.claude/jobs/a8819489/tmp/all_tables.txt"
OUT="docs/discovery/glpi-live/crosscheck.csv"

TOKEN=$(curl -s -m 25 "$BASE/initSession" -H "App-Token: $APP" \
  -u "$SIS_TEST_ADMIN_USER:$SIS_TEST_ADMIN_PASSWORD" \
  | grep -oE '"session_token"[^,]*' | grep -oE '[A-Za-z0-9]{15,}' | head -1)
[ -z "$TOKEN" ] && { echo "FALHA auth"; exit 1; }
curl -s -m 20 -X POST "$BASE/changeActiveProfile" -H "App-Token: $APP" \
  -H "Session-Token: $TOKEN" -H "Content-Type: application/json" \
  -d "{\"profiles_id\": 4}" >/dev/null 2>&1 || true

# deriva itemtype candidato a partir do nome de tabela (heurística de singularização)
itemtype_of() {
  local t="${1#glpi_}"
  # plugins: glpi_plugin_x_y -> Plugin... (deixa cru; tratados à parte)
  case "$t" in plugin_*) printf '%s' "SKIP"; return;; esac
  local out="" part
  IFS='_' read -ra parts <<< "$t"
  local last_idx=$(( ${#parts[@]} - 1 ))
  for i in "${!parts[@]}"; do
    part="${parts[$i]}"
    if [ "$i" -eq "$last_idx" ]; then
      # singulariza só a última parte
      case "$part" in
        *ies) part="${part%ies}y";;
        *ses|*xes|*ches|*shes) part="${part%es}";;
        *s) part="${part%s}";;
      esac
    fi
    out+="$(tr '[:lower:]' '[:upper:]' <<< "${part:0:1}")${part:1}"
  done
  printf '%s' "$out"
}

echo "table,itemtype,http_status,total" > "$OUT"
n=0
while read -r tbl; do
  it=$(itemtype_of "$tbl")
  [ "$it" = "SKIP" ] && { echo "$tbl,(plugin),skip,-" >> "$OUT"; continue; }
  hdr=$(curl -s -m 20 -D - -o /dev/null -H "App-Token: $APP" -H "Session-Token: $TOKEN" \
    "$BASE/$it?range=0-0" 2>/dev/null)
  code=$(printf '%s' "$hdr" | grep -oiE 'HTTP/[0-9.]+ [0-9]+' | tail -1 | grep -oE '[0-9]+$')
  total=$(printf '%s' "$hdr" | grep -oiE 'Content-Range: [^[:space:]]+' | grep -oE '/[0-9]+' | tr -d '/')
  echo "$tbl,$it,${code:-000},${total:--}" >> "$OUT"
  n=$((n+1))
done < "$TABLES"
curl -s -m 15 "$BASE/killSession" -H "App-Token: $APP" -H "Session-Token: $TOKEN" >/dev/null 2>&1 || true
echo "DONE: $n itemtypes testados. CSV: $OUT"
echo "Status:"; tail -n +2 "$OUT" | cut -d, -f3 | sort | uniq -c
