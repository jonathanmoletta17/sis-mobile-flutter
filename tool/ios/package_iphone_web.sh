#!/usr/bin/env bash
set -euo pipefail

# Build Flutter Web/PWA artifacts for iPhone/Safari testing.
# This does not touch GLPI and does not require Apple Developer/Xcode.

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
OUTDIR="${1:-/mnt/c/Users/jonathan-moletta/ops/sis-mobile/iphone-web-$(date +%Y%m%d-%H%M)}"
FLUTTER_BIN="${FLUTTER_BIN:-/opt/flutter/bin/flutter}"

if [ ! -x "$FLUTTER_BIN" ]; then
  echo "ERROR: Flutter not found at $FLUTTER_BIN" >&2
  exit 2
fi

cd "$ROOT"
BACKUP="$(mktemp)"
cp .env "$BACKUP"
restore_env() {
  cp "$BACKUP" .env
  rm -f "$BACKUP"
}
trap restore_env EXIT

build_web() {
  local app="$1"
  local env_file="$2"
  local target="$3"
  local base_href="$4"
  local title="$5"
  local description="$6"
  local dest="$OUTDIR/$app"

  if [ ! -f "$env_file" ]; then
    echo "ERROR: missing $env_file" >&2
    exit 3
  fi

  cp "$env_file" .env
  "$FLUTTER_BIN" build web --release -t "$target" --base-href "$base_href"
  rm -rf "$dest"
  mkdir -p "$dest"
  cp -a build/web/. "$dest/"

  python3 - "$dest" "$title" "$description" <<'PY'
import json
import sys
from pathlib import Path

dest = Path(sys.argv[1])
title = sys.argv[2]
description = sys.argv[3]

index = dest / 'index.html'
text = index.read_text(encoding='utf-8')
text = text.replace('<title>SIS Mobile</title>', f'<title>{title}</title>')
text = text.replace('content="Aplicativo SIS para chamados GLPI."', f'content="{description}"')
text = text.replace('content="SIS Mobile"', f'content="{title}"')
index.write_text(text, encoding='utf-8')

manifest = dest / 'manifest.json'
if manifest.exists():
    data = json.loads(manifest.read_text(encoding='utf-8'))
    data['name'] = title
    data['short_name'] = title
    data['description'] = description
    manifest.write_text(json.dumps(data, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')
PY
}

mkdir -p "$OUTDIR"
build_web "sis" ".env.public" "lib/main.dart" "/sis-mobile/" "SIS Mobile" "Aplicativo SIS para chamados GLPI."
build_web "dtic" ".env.public.dtic" "lib/main_dtic.dart" "/dtic-mobile/" "DTIC Mobile" "Aplicativo DTIC para serviços GLPI/FormCreator."

restore_env
trap - EXIT

cat > "$OUTDIR/README_IPHONE_WEB.txt" <<TXT
SIS/DTIC Mobile — iPhone Web/PWA

Hospede estes diretórios em HTTPS:
- sis/  -> base path /sis-mobile/
- dtic/ -> base path /dtic-mobile/

No iPhone:
1. Abrir a URL no Safari.
2. Compartilhar > Adicionar à Tela de Início.
3. Testar primeiro login/read-only.

Este pacote não é IPA e não instala pela App Store/TestFlight.
Ele é a alternativa imediata para iPhone sem Mac/Xcode.
TXT

find "$OUTDIR" -maxdepth 2 -type f | sort > "$OUTDIR/FILES.txt"
python3 - <<PY
from pathlib import Path
out = Path('$OUTDIR')
print(f'IPHONE_WEB_OUT={out}')
print(f'WINDOWS_PATH={str(out).replace("/mnt/c/", "C:/").replace("/", "\\\\")}')
print('SIS_INDEX=', (out/'sis/index.html').exists())
print('DTIC_INDEX=', (out/'dtic/index.html').exists())
PY
