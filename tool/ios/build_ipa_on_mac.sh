#!/usr/bin/env bash
set -euo pipefail

# Build a native iOS IPA on macOS.
# This script is intentionally fail-fast on non-macOS hosts.
# It never prints secrets. Apple signing material must be configured in Xcode or CI.

APP="${1:-sis}"
EXPORT_METHOD="${EXPORT_METHOD:-development}" # development, ad-hoc, app-store, enterprise
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
FLUTTER_BIN="${FLUTTER_BIN:-flutter}"
OUTDIR="${OUTDIR:-$ROOT/build/ios-delivery/$APP-$(date +%Y%m%d-%H%M)}"

case "$APP" in
  sis)
    ENV_FILE=".env.public"
    TARGET="lib/main.dart"
    EXPECTED_BUNDLE="br.gov.rs.casacivil.sismobile"
    ;;
  dtic)
    ENV_FILE=".env.public.dtic"
    TARGET="lib/main_dtic.dart"
    EXPECTED_BUNDLE="br.gov.rs.casacivil.dticmobile"
    ;;
  *)
    echo "Usage: $0 sis|dtic" >&2
    exit 2
    ;;
esac

if [ "$(uname -s)" != "Darwin" ]; then
  echo "ERROR: iOS native build requires macOS. Current OS: $(uname -s)" >&2
  exit 10
fi

for cmd in xcodebuild "$FLUTTER_BIN"; do
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "ERROR: required command not found: $cmd" >&2
    exit 11
  fi
done

cd "$ROOT"
if [ ! -f "$ENV_FILE" ]; then
  echo "ERROR: missing $ENV_FILE" >&2
  exit 12
fi

if [ ! -d ios ]; then
  echo "ERROR: missing ios/ project directory" >&2
  exit 13
fi

mkdir -p "$OUTDIR"
BACKUP="$(mktemp)"
cp .env "$BACKUP"
restore_env() {
  cp "$BACKUP" .env
  rm -f "$BACKUP"
}
trap restore_env EXIT

cp "$ENV_FILE" .env

"$FLUTTER_BIN" doctor -v
"$FLUTTER_BIN" pub get

# CocoaPods is optional for simple projects but normally required by Flutter plugins.
if command -v pod >/dev/null 2>&1; then
  (cd ios && pod install)
else
  echo "WARN: CocoaPods not found; Flutter may fail if iOS plugins need pods." >&2
fi

# Gate: current iOS project is SIS-native by default. DTIC requires a dedicated
# bundle id/scheme/signing configuration before a valid DTIC IPA can be proven.
if [ "$APP" = "dtic" ]; then
  if ! grep -q "br.gov.rs.casacivil.dticmobile" ios/Runner.xcodeproj/project.pbxproj; then
    echo "ERROR: DTIC iOS bundle id is not configured in Xcode project yet." >&2
    echo "Configure a DTIC scheme/target or apply the iOS flavor project changes before building DTIC IPA." >&2
    exit 20
  fi
fi

# Use the default Runner scheme unless the Mac project has explicit flavor schemes.
SCHEME_ARG=()
if xcodebuild -list -project ios/Runner.xcodeproj 2>/dev/null | grep -Eq "^[[:space:]]+$APP$"; then
  SCHEME_ARG=(--flavor "$APP")
fi

"$FLUTTER_BIN" build ipa --release "${SCHEME_ARG[@]}" -t "$TARGET" --export-method "$EXPORT_METHOD"

IPA=$(find build/ios/ipa -maxdepth 1 -name '*.ipa' -type f | sort | tail -1 || true)
if [ -z "$IPA" ]; then
  echo "ERROR: IPA not found under build/ios/ipa" >&2
  exit 30
fi

cp "$IPA" "$OUTDIR/"
shasum -a 256 "$OUTDIR"/*.ipa > "$OUTDIR/SHA256SUMS.txt"

cat > "$OUTDIR/VALIDACAO_IOS.txt" <<TXT
App: $APP
Target: $TARGET
Expected bundle: $EXPECTED_BUNDLE
Export method: $EXPORT_METHOD
Generated on: $(date -Iseconds)

Next gates:
1. Install through Xcode, Apple Configurator, MDM, or TestFlight.
2. Open app on real iPhone.
3. Run login/read-only smoke first.
4. Do not run mutable GLPI flow without explicit synthetic-ticket approval.
TXT

restore_env
trap - EXIT

echo "IPA_OUTDIR=$OUTDIR"
ls -la "$OUTDIR"
