#!/usr/bin/env bash
set -euo pipefail

# Read-only Android smoke for SIS/DTIC Mobile APK artifacts.
# Safety contract:
# - no credentials are read, typed, dumped or screenshotted;
# - no GLPI login/initSession is executed;
# - no ticket/followup/attachment/status/solution/DELETE/purge/cleanup is executed;
# - only APK integrity, install, launch, screenshot, package metadata and crash absence are validated.

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
ANDROID_HOME_DEFAULT="/home/jonathan/Android/Sdk"
ANDROID_HOME="${ANDROID_HOME:-$ANDROID_HOME_DEFAULT}"
ADB="$ANDROID_HOME/platform-tools/adb"
EMULATOR="$ANDROID_HOME/emulator/emulator"
AAPT="${AAPT:-$ANDROID_HOME/build-tools/36.0.0/aapt}"
AVD_NAME="${AVD_NAME:-hermes_sis_mobile_api35}"
ANDROID_AVD_HOME="${ANDROID_AVD_HOME:-/home/jonathan/.android/avd}"
OUT_DIR="${OUT_DIR:-/home/jonathan/.brain/evidence/sis-mobile/android-smoke-$(date +%Y%m%d-%H%M%S)}"
SIS_APK="${SIS_APK:-}"
DTIC_APK="${DTIC_APK:-}"
ALLOW_KVM_CHMOD=0
KEEP_EMULATOR=0
SKIP_DTIC=0
SERIAL="${SERIAL:-}"
EMULATOR_SESSION_STARTED=0
EMULATOR_PID=""
KVM_ORIGINAL_MODE=""

usage() {
  cat <<'USAGE'
Usage:
  tool/android/readonly_smoke_android.sh --sis-apk <apk> [--dtic-apk <apk>] [--skip-dtic] [--allow-kvm-chmod] [--keep-emulator]

Environment overrides:
  ANDROID_HOME       Android SDK root (default: /home/jonathan/Android/Sdk)
  AVD_NAME           AVD name (default: hermes_sis_mobile_api35)
  ANDROID_AVD_HOME   AVD directory (default: /home/jonathan/.android/avd)
  SERIAL             Existing Android serial to reuse (optional)
  SIS_APK            SIS APK path (or --sis-apk)
  DTIC_APK           DTIC APK path (or --dtic-apk)
  OUT_DIR            Evidence output directory

Important runtime rule:
  On CC-PC-WS1655947, the working AVDs are in WSL:
    /home/jonathan/Android/Sdk
    /home/jonathan/.android/avd/hermes_sis_mobile_api35.avd
  Windows has Android SDK, but may have no AVDs. Do not conclude that no emulator exists
  from Windows emulator.exe -list-avds alone.

Safety:
  - No credentials are read or typed.
  - No UI dump is taken from password fields.
  - No GLPI login/initSession is executed.
  - No ticket/followup/attachment/status/solution mutation is executed.
USAGE
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --sis-apk) SIS_APK="${2:?missing --sis-apk value}"; shift ;;
    --dtic-apk) DTIC_APK="${2:?missing --dtic-apk value}"; shift ;;
    --skip-dtic) SKIP_DTIC=1 ;;
    --serial) SERIAL="${2:?missing --serial value}"; shift ;;
    --allow-kvm-chmod) ALLOW_KVM_CHMOD=1 ;;
    --keep-emulator) KEEP_EMULATOR=1 ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown arg: $1" >&2; usage; exit 2 ;;
  esac
  shift
done

log() { printf '[%s] %s\n' "$(date +%H:%M:%S)" "$*" | tee -a "$OUT_DIR/run.log"; }
run() { log "+ $*"; "$@" 2>&1 | tee -a "$OUT_DIR/run.log"; }

timeout_run() {
  local seconds="$1"
  shift
  /usr/bin/timeout "$seconds" "$@"
}

restore_kvm() {
  if [[ -n "$KVM_ORIGINAL_MODE" && -e /dev/kvm ]]; then
    sudo chmod "$KVM_ORIGINAL_MODE" /dev/kvm >/dev/null 2>&1 || true
  fi
}

cleanup() {
  restore_kvm
  if [[ "$KEEP_EMULATOR" != "1" && "$EMULATOR_SESSION_STARTED" == "1" && -n "$EMULATOR_PID" ]]; then
    kill "$EMULATOR_PID" >/dev/null 2>&1 || true
    sleep 2
    kill -9 "$EMULATOR_PID" >/dev/null 2>&1 || true
  fi
}
trap cleanup EXIT

mkdir -p "$OUT_DIR"

if [[ -z "$SIS_APK" ]]; then
  echo "Missing SIS APK. Pass --sis-apk <apk> or set SIS_APK." >&2
  usage >&2
  exit 3
fi
if [[ "$SKIP_DTIC" != "1" && -z "$DTIC_APK" ]]; then
  echo "Missing DTIC APK. Pass --dtic-apk <apk>, or use --skip-dtic for SIS-only validation." >&2
  usage >&2
  exit 3
fi

{
  echo "host=$(hostname)"
  echo "repo_root=$REPO_ROOT"
  echo "pwd=$(pwd)"
  echo "git_root=$(git -C "$REPO_ROOT" rev-parse --show-toplevel 2>/dev/null || true)"
  echo "branch=$(git -C "$REPO_ROOT" branch --show-current 2>/dev/null || true)"
  echo "path_class=WSL ext4 canonical project root under /home/jonathan/projects"
  echo "android_home=$ANDROID_HOME"
  echo "android_avd_home=$ANDROID_AVD_HOME"
  echo "avd_name=$AVD_NAME"
  echo "serial_requested=$SERIAL"
  echo "out_dir=$OUT_DIR"
  echo "sis_apk=$SIS_APK"
  echo "dtic_apk=$DTIC_APK"
  echo "skip_dtic=$SKIP_DTIC"
} | tee "$OUT_DIR/context.txt" >/dev/null

log "Starting read-only Android smoke. No GLPI credentials or mutations will be used."

for bin in "$ADB" "$EMULATOR" "$AAPT"; do
  [[ -x "$bin" ]] || { echo "Missing executable: $bin" >&2; exit 4; }
done

prepare_apk() {
  local input="$1"
  local label="$2"
  [[ -f "$input" ]] || { echo "Missing $label APK: $input" >&2; exit 4; }
  local output="$OUT_DIR/${label}.apk"
  cp "$input" "$output"
  sha256sum "$input" "$output" | tee -a "$OUT_DIR/apk-sha256.txt" >&2
  unzip -tq "$output" >&2
  "$AAPT" dump badging "$output" \
    | grep -E "^package:|^sdkVersion:|^targetSdkVersion:|^application-label:'|^launchable-activity:" \
    | head -12 \
    | sed "s#^#$label:#" \
    | tee -a "$OUT_DIR/apk-badging.txt" >&2
  for env_asset in assets/flutter_assets/.env assets/flutter_assets/.env.public; do
    unzip -p "$output" "$env_asset" 2>/dev/null \
      | grep -E '^(GLPI_BASE_URL|SIS_GLPI_BASE_URL|SIS_METADATA_CATALOG_URL|DTIC_GLPI_BASE_URL|GLPI_DEBUG_LOGS|DTIC_ENABLE_FORM_SUBMISSION|DTIC_ENABLE_TICKET_ACTIONS)' \
      | sed -E 's#(https?://)[^/ ]+#\1<host>#g' \
      | sed "s#^#$label:$env_asset:#" \
      | tee -a "$OUT_DIR/apk-public-env.txt" >&2 || true
  done
  printf '%s\n' "$output"
}

SIS_LOCAL_APK="$(prepare_apk "$SIS_APK" sis)"
DTIC_LOCAL_APK=""
if [[ "$SKIP_DTIC" != "1" ]]; then
  DTIC_LOCAL_APK="$(prepare_apk "$DTIC_APK" dtic)"
fi

if [[ -e /dev/kvm ]]; then
  KVM_ORIGINAL_MODE="$(stat -c '%a' /dev/kvm)"
  log "Current /dev/kvm mode: $KVM_ORIGINAL_MODE"
  if [[ ! -r /dev/kvm || ! -w /dev/kvm ]]; then
    if [[ "$ALLOW_KVM_CHMOD" == "1" ]]; then
      log "Temporarily enabling current-user KVM access via sudo chmod o+rw /dev/kvm; will restore on exit."
      sudo chmod o+rw /dev/kvm
    else
      log "KVM not readable/writable. Re-run with --allow-kvm-chmod if approved."
      exit 5
    fi
  fi
fi

if ! timeout_run 20s "$ADB" start-server | tee -a "$OUT_DIR/run.log"; then
  log "ADB start-server timed out or failed. Check $OUT_DIR and stale adb state."
  exit 6
fi

if ! HOME=/home/jonathan ANDROID_AVD_HOME="$ANDROID_AVD_HOME" "$EMULATOR" -list-avds | tee "$OUT_DIR/avds.txt" | grep -qx "$AVD_NAME"; then
  log "AVD not found: $AVD_NAME. On this host, check WSL AVD home before checking Windows-only AVDs."
  exit 7
fi

if [[ -z "$SERIAL" ]]; then
  SERIAL="$($ADB devices | awk 'NR>1 && $2=="device"{print $1; exit}')"
fi

if [[ -z "$SERIAL" ]]; then
  log "Starting headless WSL emulator $AVD_NAME"
  HOME=/home/jonathan ANDROID_AVD_HOME="$ANDROID_AVD_HOME" \
    "$EMULATOR" -avd "$AVD_NAME" -no-window -no-audio -no-snapshot -gpu swiftshader_indirect \
    >"$OUT_DIR/emulator.log" 2>&1 &
  EMULATOR_PID=$!
  EMULATOR_SESSION_STARTED=1
fi

for _ in $(seq 1 180); do
  SERIAL="$($ADB devices | awk 'NR>1 && $2=="device"{print $1; exit}')"
  [[ -n "$SERIAL" ]] && break
  sleep 2
done
[[ -n "$SERIAL" ]] || { log "No Android device became ready."; exit 8; }

for _ in $(seq 1 240); do
  boot="$($ADB -s "$SERIAL" shell getprop sys.boot_completed 2>/dev/null | tr -d '\r' || true)"
  bootanim="$($ADB -s "$SERIAL" shell getprop init.svc.bootanim 2>/dev/null | tr -d '\r' || true)"
  [[ "$boot" == "1" && "$bootanim" == "stopped" ]] && break
  sleep 2
done
boot="$($ADB -s "$SERIAL" shell getprop sys.boot_completed | tr -d '\r')"
bootanim="$($ADB -s "$SERIAL" shell getprop init.svc.bootanim | tr -d '\r')"
[[ "$boot" == "1" ]] || { log "Device did not complete boot."; exit 9; }
log "Device boot state: sys.boot_completed=$boot bootanim=$bootanim"

{
  echo "serial=$SERIAL"
  echo "boot_completed=$boot"
  echo "bootanim=$bootanim"
  "$ADB" -s "$SERIAL" shell wm size
  "$ADB" -s "$SERIAL" shell getprop ro.build.version.release
  "$ADB" -s "$SERIAL" devices -l || true
} | tee "$OUT_DIR/device.txt"

"$ADB" -s "$SERIAL" shell settings put global window_animation_scale 0 || true
"$ADB" -s "$SERIAL" shell settings put global transition_animation_scale 0 || true
"$ADB" -s "$SERIAL" shell settings put global animator_duration_scale 0 || true

install_apk() {
  local apk="$1"
  local package="$2"
  run "$ADB" -s "$SERIAL" install --no-streaming -r "$apk"
  "$ADB" -s "$SERIAL" shell pm clear "$package" | tee -a "$OUT_DIR/run.log"
  "$ADB" -s "$SERIAL" shell dumpsys package "$package" \
    | grep -E 'Package \[|versionName|versionCode|firstInstallTime|lastUpdateTime' \
    > "$OUT_DIR/${package}-dumpsys.txt" || true
}

install_apk "$SIS_LOCAL_APK" br.gov.rs.casacivil.sismobile
if [[ "$SKIP_DTIC" != "1" ]]; then
  install_apk "$DTIC_LOCAL_APK" br.gov.rs.casacivil.dticmobile
fi

"$ADB" -s "$SERIAL" shell pm list packages | grep -E 'br.gov.rs.casacivil.(sis|dtic)mobile' | tee "$OUT_DIR/packages.txt"

# SIS launch only; no credentials or UI dump after typing.
"$ADB" -s "$SERIAL" logcat -c
"$ADB" -s "$SERIAL" shell monkey -p br.gov.rs.casacivil.sismobile -c android.intent.category.LAUNCHER 1 | tee -a "$OUT_DIR/run.log"
sleep 10
"$ADB" -s "$SERIAL" exec-out screencap -p > "$OUT_DIR/sis-login.png"
"$ADB" -s "$SERIAL" shell dumpsys activity activities > "$OUT_DIR/sis-activity.txt" || true
"$ADB" -s "$SERIAL" logcat -d -t 1200 > "$OUT_DIR/sis-logcat-tail.txt"
"$ADB" -s "$SERIAL" shell am force-stop br.gov.rs.casacivil.sismobile || true

if [[ "$SKIP_DTIC" != "1" ]]; then
  "$ADB" -s "$SERIAL" logcat -c
  "$ADB" -s "$SERIAL" shell monkey -p br.gov.rs.casacivil.dticmobile -c android.intent.category.LAUNCHER 1 | tee -a "$OUT_DIR/run.log"
  sleep 10
  "$ADB" -s "$SERIAL" exec-out screencap -p > "$OUT_DIR/dtic-login.png"
  "$ADB" -s "$SERIAL" shell dumpsys activity activities > "$OUT_DIR/dtic-activity.txt" || true
  "$ADB" -s "$SERIAL" logcat -d -t 1200 > "$OUT_DIR/dtic-logcat-tail.txt"
fi

if grep -E 'FATAL EXCEPTION|Force finishing|Fatal signal' "$OUT_DIR"/*-logcat-tail.txt >/dev/null; then
  log "Crash signature found in logcat. See $OUT_DIR/*-logcat-tail.txt"
  exit 10
fi

cat > "$OUT_DIR/summary.txt" <<EOF
READ-ONLY ANDROID SMOKE PASSED
No credentials used.
No GLPI login/initSession executed.
No ticket/followup/attachment/status/solution/DELETE/purge/cleanup executed.
SIS installed and launched.
DTIC skipped: $SKIP_DTIC
No FATAL EXCEPTION / Force finishing / Fatal signal found in captured app logcat tails.
EOF

find "$OUT_DIR" -maxdepth 1 -type f -printf '%f %s bytes\n' | sort | tee "$OUT_DIR/files.txt"
log "Read-only Android smoke completed: $OUT_DIR"
