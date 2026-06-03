#!/usr/bin/env bash
set -euo pipefail

# Authenticated read-only Android smoke for SIS Mobile.
# Safety contract:
# - loads credentials from a local secret file but never prints values;
# - does not use uiautomator dump;
# - does not capture screenshot while credentials are being typed;
# - does not create, update, delete, purge, attach, solve, approve, reject, or follow up tickets;
# - validates only login/navigation state and captures post-login/logcat evidence.

ANDROID_HOME="${ANDROID_HOME:-/home/jonathan/Android/Sdk}"
ADB="$ANDROID_HOME/platform-tools/adb"
SERIAL="${SERIAL:-emulator-5554}"
PKG="${PKG:-br.gov.rs.casacivil.sismobile}"
SECRET_FILE="${SECRET_FILE:-/home/jonathan/.hermes/secrets/sis-mobile-e2e.env}"
ROLE="${ROLE:-requester}"
OUT_DIR="${OUT_DIR:-/home/jonathan/.brain/evidence/sis-mobile/auth-readonly-$(date +%Y%m%d-%H%M%S)}"

usage() {
  cat <<'USAGE'
Usage:
  tool/android/auth_readonly_smoke_android.sh [--role requester|technician] [--serial emulator-5554]

Environment:
  SECRET_FILE  default /home/jonathan/.hermes/secrets/sis-mobile-e2e.env
  OUT_DIR      evidence directory
  ANDROID_HOME default /home/jonathan/Android/Sdk

Safety:
  No credential values are printed.
  No uiautomator dump is used.
  No GLPI mutation is executed.
USAGE
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --role) ROLE="${2:?missing --role value}"; shift ;;
    --serial) SERIAL="${2:?missing --serial value}"; shift ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown arg: $1" >&2; usage; exit 2 ;;
  esac
  shift
done

mkdir -p "$OUT_DIR"
log() { printf '[%s] %s\n' "$(date +%H:%M:%S)" "$*" | tee -a "$OUT_DIR/run.log"; }

[[ -x "$ADB" ]] || { echo "Missing adb: $ADB" >&2; exit 3; }
[[ -f "$SECRET_FILE" ]] || { echo "Missing secret file: $SECRET_FILE" >&2; exit 3; }

set +x
# shellcheck disable=SC1090
source "$SECRET_FILE"
set -x >/dev/null 2>&1 || true
set +x

case "$ROLE" in
  requester)
    USERNAME="${GLPI_SIS_REQUESTER_USERNAME:-}"
    PASSWORD="${GLPI_SIS_REQUESTER_PASSWORD:-}"
    ;;
  technician)
    USERNAME="${GLPI_SIS_TECHNICIAN_USERNAME:-}"
    PASSWORD="${GLPI_SIS_TECHNICIAN_PASSWORD:-}"
    ;;
  *) echo "Invalid role: $ROLE" >&2; exit 2 ;;
esac

[[ -n "$USERNAME" && -n "$PASSWORD" ]] || { echo "Missing username/password for role $ROLE" >&2; exit 3; }

adb_input_text() {
  # Android input text escaping. Values are never printed.
  local text="$1"
  local escaped="$text"
  escaped="${escaped//%/%25}"
  escaped="${escaped// /%s}"
  escaped="${escaped//&/\\&}"
  escaped="${escaped//</\\<}"
  escaped="${escaped//>/\\>}"
  escaped="${escaped//\(/\\(}"
  escaped="${escaped//\)/\\)}"
  escaped="${escaped//;/\\;}"
  escaped="${escaped//|/\\|}"
  escaped="${escaped//\*/\\*}"
  escaped="${escaped//#/\\#}"
  escaped="${escaped//$/\\$}"
  "$ADB" -s "$SERIAL" shell input text "$escaped" >/dev/null
}

{
  echo "host=$(hostname)"
  echo "serial=$SERIAL"
  echo "package=$PKG"
  echo "role=$ROLE"
  echo "secret_file=$SECRET_FILE"
  echo "safety=no-ui-dump,no-credential-screenshot,no-glpi-mutation"
  "$ADB" -s "$SERIAL" devices -l || true
} > "$OUT_DIR/context.txt"

log "Starting AUTH_READONLY smoke for role=$ROLE. Credential values will not be printed."
"$ADB" -s "$SERIAL" shell getprop sys.boot_completed > "$OUT_DIR/boot_completed.txt" || true
"$ADB" -s "$SERIAL" shell pm path "$PKG" > "$OUT_DIR/pm-path.txt"
"$ADB" -s "$SERIAL" shell dumpsys package "$PKG" > "$OUT_DIR/package-before.txt" || true

# Start from clean app state. This removes previous tokens/session and prevents stale auth.
"$ADB" -s "$SERIAL" shell pm clear "$PKG" >> "$OUT_DIR/run.log"
"$ADB" -s "$SERIAL" logcat -c || true
"$ADB" -s "$SERIAL" shell monkey -p "$PKG" -c android.intent.category.LAUNCHER 1 >> "$OUT_DIR/run.log"
sleep 8

# Coordinates for 1080x2400 login card validated from screenshot.
# No screenshot after typing credentials.
log "Typing username/password via coordinate input without UI dump."
"$ADB" -s "$SERIAL" shell input tap 540 1380 >/dev/null
adb_input_text "$USERNAME"
sleep 1
# Move focus to password field through keyboard navigation instead of tapping
# fixed coordinates after the soft keyboard changes the layout.
"$ADB" -s "$SERIAL" shell input keyevent 61 >/dev/null
sleep 1
adb_input_text "$PASSWORD"
sleep 1
# Submit from password field. This avoids tapping a button that may be covered
# or shifted by the keyboard.
"$ADB" -s "$SERIAL" shell input keyevent 66 >/dev/null

log "Waiting for post-login navigation/network."
sleep 18

"$ADB" -s "$SERIAL" shell dumpsys activity activities > "$OUT_DIR/activity-after-login.txt" || true
"$ADB" -s "$SERIAL" logcat -d -t 1800 > "$OUT_DIR/logcat-after-login.txt" || true
# Post-login screenshot only. If login failed, password field is Android-masked; still treat file as sensitive evidence.
"$ADB" -s "$SERIAL" exec-out screencap -p > "$OUT_DIR/post-login.png"
sha256sum "$OUT_DIR/post-login.png" > "$OUT_DIR/post-login.sha256"

# Heuristic evidence without UI dump.
if grep -Eiq 'ERROR_APP_TOKEN_PARAMETERS_MISSING' "$OUT_DIR/logcat-after-login.txt"; then
  echo "AUTH_READONLY_FAILED_APP_TOKEN" > "$OUT_DIR/verdict.txt"
  log "Detected ERROR_APP_TOKEN_PARAMETERS_MISSING in logcat."
  exit 10
fi
if grep -Eiq 'FATAL EXCEPTION|Fatal signal|Force finishing' "$OUT_DIR/logcat-after-login.txt"; then
  echo "AUTH_READONLY_FAILED_CRASH" > "$OUT_DIR/verdict.txt"
  log "Detected crash signature in logcat."
  exit 11
fi

cat > "$OUT_DIR/verdict.txt" <<EOF
AUTH_READONLY_EXECUTED
No credential values printed.
No uiautomator dump used.
No GLPI mutation command executed by this script.
No ERROR_APP_TOKEN_PARAMETERS_MISSING found in captured logcat.
No FATAL EXCEPTION / Fatal signal / Force finishing found in captured logcat.
Manual/visual review of post-login.png is required to classify navigation screen.
EOF

find "$OUT_DIR" -maxdepth 1 -type f -printf '%f %s bytes\n' | sort > "$OUT_DIR/files.txt"
log "AUTH_READONLY smoke completed: $OUT_DIR"
