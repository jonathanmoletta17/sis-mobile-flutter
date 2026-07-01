#!/usr/bin/env bash
set -euo pipefail

# Checagem leve de fronteira SIS/DTIC: lib/dtic/ so pode importar, de fora de si
# mesmo, o que estiver na lista de diretorios/arquivos compartilhados por contrato.
# Sem essa checagem, um import direto de lib/screens/ ou lib/state/ (SIS-especifico)
# dentro de lib/dtic/ so seria pego em revisao manual — ja aconteceu uma vez com IDs
# de grupo hardcoded vazando entre as duas linhas.
#
# Ver docs/decisions/2026-07-01-padronizacao-sis-dtic.md e
# docs/PADRONIZACAO_APPS_SIS_DTIC.md para o contrato completo.
#
# Uso: tool/check_sis_dtic_boundary.sh

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LIB_DIR="$REPO_ROOT/lib"
DTIC_DIR="$LIB_DIR/dtic"

# Prefixos absolutos permitidos fora de lib/dtic/ (fronteira compartilhada por contrato)
ALLOWED_PREFIXES=(
  "$LIB_DIR/theme/"
  "$LIB_DIR/widgets/ui/"
  "$LIB_DIR/utils/"
  "$LIB_DIR/models/glpi_status.dart"
)

violations=0

while IFS= read -r -d '' file; do
  file_dir="$(dirname "$file")"
  while IFS= read -r import_path; do
    case "$import_path" in
      package:sis_mobile_flutter/*)
        rel="${import_path#package:sis_mobile_flutter/}"
        resolved="$LIB_DIR/$rel"
        ;;
      .*)
        resolved="$(cd "$file_dir" && realpath -m "$import_path" 2>/dev/null || true)"
        ;;
      *)
        continue
        ;;
    esac
    [ -z "$resolved" ] && continue

    case "$resolved" in
      "$DTIC_DIR"/*|"$DTIC_DIR") continue ;;
    esac

    allowed=0
    for prefix in "${ALLOWED_PREFIXES[@]}"; do
      case "$resolved" in
        "$prefix"*) allowed=1; break ;;
      esac
    done

    if [ "$allowed" -eq 0 ]; then
      echo "VIOLACAO: ${file#"$REPO_ROOT"/} importa '$import_path' (fora da fronteira compartilhada SIS/DTIC)"
      violations=$((violations + 1))
    fi
  done < <(grep -oE "^import '[^']+'" "$file" | sed -E "s/^import '([^']+)'/\1/")
done < <(find "$DTIC_DIR" -name "*.dart" -print0)

if [ "$violations" -gt 0 ]; then
  echo ""
  echo "$violations importacao(oes) fora da fronteira compartilhada SIS/DTIC."
  echo "Fronteira compartilhada por contrato: lib/theme/, lib/widgets/ui/, lib/utils/, lib/models/glpi_status.dart."
  echo "Ver docs/decisions/2026-07-01-padronizacao-sis-dtic.md."
  exit 1
fi

echo "OK: nenhuma importacao de lib/dtic/ cruza a fronteira compartilhada SIS/DTIC."
