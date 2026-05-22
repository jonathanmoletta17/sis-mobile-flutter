#!/usr/bin/env bash
set -euo pipefail

# Build a Cloudflare Pages-compatible static bundle for SIS/DTIC Mobile PWA.
# Safe/local: does not deploy. It only creates a publish directory and validates
# that the bundle contains the runtime metadata wiring required by SIS Mobile.

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
OUTDIR="${1:-/home/jonathan/.brain/artifacts/sis-dtic-mobile-pwa-pages-$(date +%Y%m%d-%H%M%S)}"
FLUTTER_BIN="${FLUTTER_BIN:-/opt/flutter/bin/flutter}"

if [ ! -x "$FLUTTER_BIN" ]; then
  echo "ERROR: Flutter not found at $FLUTTER_BIN" >&2
  exit 2
fi

cd "$ROOT"

require_file() {
  local path="$1"
  if [ ! -f "$path" ]; then
    echo "ERROR: missing required file: $path" >&2
    exit 3
  fi
}

validate_sis_bundle() {
  local dest="$1"
  local js="$dest/main.dart.js"
  local env="$dest/assets/.env.public"

  require_file "$js"
  require_file "$env"

  grep -q 'SIS_METADATA_CATALOG_URL' "$js" || {
    echo "ERROR: SIS bundle main.dart.js does not contain SIS_METADATA_CATALOG_URL wiring" >&2
    exit 10
  }
  grep -q '.env.public' "$js" || {
    echo "ERROR: SIS bundle main.dart.js does not reference .env.public; ENV_FILE was probably omitted" >&2
    exit 11
  }
  grep -q '^SIS_METADATA_CATALOG_URL=' "$env" || {
    echo "ERROR: SIS bundle assets/.env.public lacks SIS_METADATA_CATALOG_URL" >&2
    exit 12
  }
}

validate_dtic_bundle() {
  local dest="$1"
  local js="$dest/main.dart.js"
  local env="$dest/assets/.env.public.dtic"

  require_file "$js"
  require_file "$env"

  grep -q '.env.public.dtic' "$js" || {
    echo "ERROR: DTIC bundle main.dart.js does not reference .env.public.dtic; ENV_FILE was probably omitted" >&2
    exit 20
  }
  grep -q '^DTIC_GLPI_BASE_URL=' "$env" || {
    echo "ERROR: DTIC bundle assets/.env.public.dtic lacks DTIC_GLPI_BASE_URL" >&2
    exit 21
  }
}

build_web() {
  local app="$1"
  local env_file="$2"
  local target="$3"
  local base_href="$4"
  local title="$5"
  local description="$6"
  local dest="$OUTDIR/$app"

  require_file "$env_file"
  echo "## Building $app -> $dest"
  "$FLUTTER_BIN" build web --release \
    -t "$target" \
    --base-href "$base_href" \
    --dart-define=ENV_FILE="$env_file"

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

rm -rf "$OUTDIR"
mkdir -p "$OUTDIR"

build_web "sis-mobile" ".env.public" "lib/main.dart" "/sis-mobile/" "SIS Mobile" "Aplicativo SIS para chamados GLPI."
validate_sis_bundle "$OUTDIR/sis-mobile"

build_web "dtic-mobile" ".env.public.dtic" "lib/main_dtic.dart" "/dtic-mobile/" "DTIC Mobile" "Aplicativo DTIC para serviços GLPI/FormCreator."
validate_dtic_bundle "$OUTDIR/dtic-mobile"

find "$OUTDIR" -maxdepth 3 -type f | sort > "$OUTDIR/FILES.txt"
cat > "$OUTDIR/README_PAGES_DEPLOY.txt" <<TXT
SIS/DTIC Mobile PWA — Cloudflare Pages bundle

Publish directory contents:
- sis-mobile/  -> route /sis-mobile/
- dtic-mobile/ -> route /dtic-mobile/

Validation already performed by this script:
- SIS main.dart.js references SIS_METADATA_CATALOG_URL and .env.public
- SIS assets/.env.public contains SIS_METADATA_CATALOG_URL
- DTIC main.dart.js references .env.public.dtic
- DTIC assets/.env.public.dtic contains DTIC_GLPI_BASE_URL

Deploy is intentionally not performed by this script.
External publication requires explicit human approval.
TXT

cat <<TXT
PAGES_PWA_OUT=$OUTDIR
SIS_INDEX=$OUTDIR/sis-mobile/index.html
DTIC_INDEX=$OUTDIR/dtic-mobile/index.html
TXT
