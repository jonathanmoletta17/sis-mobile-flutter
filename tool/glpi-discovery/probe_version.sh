#!/usr/bin/env bash
# Read-only: detecta versão do GLPI SIS direto. Não imprime credenciais nem token.
set -euo pipefail
cd /home/jonathan/projects/work/mobile/sis-mobile-flutter
# Parser robusto: não reinterpreta valores (senhas com ! / espaço quebram `source`)
while IFS='=' read -r key val; do
  [[ "$key" =~ ^[A-Za-z_][A-Za-z0-9_]*$ ]] || continue
  val="${val%$'\r'}"
  export "$key=$val"
done < .env

BASE="${SIS_TEST_BASE_URL%/}"
APP="${GLPI_APP_TOKEN:-}"

mask() { sed -E 's/[A-Za-z0-9]{20,}/REDACTED/g'; }

# initSession (Basic auth da conta de teste + App-Token)
resp=$(curl -s -m 25 -w $'\n%{http_code}' "$BASE/initSession" \
  -H "App-Token: $APP" -H "Content-Type: application/json" \
  -u "$SIS_TEST_USER:$SIS_TEST_PASSWORD" || true)
code=$(printf '%s' "$resp" | tail -1)
body=$(printf '%s' "$resp" | sed '$d')
echo "initSession HTTP: $code"
if [ "$code" != "200" ]; then
  echo "FALHA. Corpo (mascarado): $(printf '%s' "$body" | head -c 300 | mask)"; exit 1
fi
TOKEN=$(printf '%s' "$body" | grep -oE '"session_token"[[:space:]]*:[[:space:]]*"[^"]+"' | grep -oE '[A-Za-z0-9]{15,}' | head -1)
[ -z "$TOKEN" ] && { echo "sem session_token"; exit 1; }
echo "Sessão estabelecida (token capturado, não exibido)."

# getGlpiConfig -> versão
cfg=$(curl -s -m 25 "$BASE/getGlpiConfig" -H "App-Token: $APP" -H "Session-Token: $TOKEN" || true)
echo "Versão (cfg): $(printf '%s' "$cfg" | grep -oE '"version"[[:space:]]*:[[:space:]]*"[^"]+"' | head -1)"
echo "DB version:   $(printf '%s' "$cfg" | grep -oE '"dbversion"[[:space:]]*:[[:space:]]*"[^"]+"' | head -1)"

# killSession (limpeza)
curl -s -m 15 "$BASE/killSession" -H "App-Token: $APP" -H "Session-Token: $TOKEN" >/dev/null 2>&1 || true
echo "Sessão encerrada."
