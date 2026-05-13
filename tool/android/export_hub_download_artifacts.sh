#!/usr/bin/env bash

set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
channel="${1:-release}"
destination_root="${2:-$repo_root/output/hub-mobile-downloads}"
source_dir="${SOURCE_DIR:-$repo_root/build/app/outputs/flutter-apk}"

case "$channel" in
  debug|release)
    ;;
  *)
    echo "Canal invalido: $channel. Use 'debug' ou 'release'." >&2
    exit 1
    ;;
esac

version_line="$(rg '^version:' "$repo_root/pubspec.yaml" -m1)"
app_version="${version_line#version: }"
app_version_name="${app_version%%+*}"
generated_at="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"

downloads_dir="$destination_root/downloads/mobile"
mkdir -p "$downloads_dir"

copy_artifact() {
  local app_id="$1"
  local source_file="$2"
  local target_file="$3"

  if [[ ! -f "$source_file" ]]; then
    echo "Artefato ausente para $app_id: $source_file" >&2
    return 1
  fi

  cp "$source_file" "$target_file"
  sha256sum "$target_file" | awk '{print $1}' > "${target_file}.sha256"
}

sis_source="$source_dir/app-sis-${channel}.apk"
dtic_source="$source_dir/app-dtic-${channel}.apk"
sis_target="$downloads_dir/sis-mobile.apk"
dtic_target="$downloads_dir/dtic-mobile.apk"

copy_artifact "sis" "$sis_source" "$sis_target"
copy_artifact "dtic" "$dtic_source" "$dtic_target"

sis_sha256="$(cat "${sis_target}.sha256")"
dtic_sha256="$(cat "${dtic_target}.sha256")"

cat > "$downloads_dir/mobile-apps.json" <<EOF
{
  "generatedAt": "$generated_at",
  "channel": "$channel",
  "version": "$app_version_name",
  "apps": [
    {
      "id": "sis",
      "name": "SIS Mobile",
      "status": "available",
      "packageId": "br.gov.rs.casacivil.sismobile",
      "version": "$app_version_name",
      "downloadPath": "/downloads/mobile/sis-mobile.apk",
      "checksumPath": "/downloads/mobile/sis-mobile.apk.sha256",
      "sha256": "$sis_sha256"
    },
    {
      "id": "dtic",
      "name": "DTIC Mobile",
      "status": "available",
      "packageId": "br.gov.rs.casacivil.dticmobile",
      "version": "$app_version_name",
      "downloadPath": "/downloads/mobile/dtic-mobile.apk",
      "checksumPath": "/downloads/mobile/dtic-mobile.apk.sha256",
      "sha256": "$dtic_sha256"
    },
    {
      "id": "rh",
      "name": "RH Mobile",
      "status": "coming_soon"
    },
    {
      "id": "dmp",
      "name": "DMP Mobile",
      "status": "coming_soon"
    }
  ]
}
EOF

cat <<EOF
Export concluido.
- Canal: $channel
- Destino: $downloads_dir
- SIS: $sis_target
- DTIC: $dtic_target
- Manifesto: $downloads_dir/mobile-apps.json
EOF
