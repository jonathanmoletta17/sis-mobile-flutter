#!/usr/bin/env bash
set -euo pipefail

# Read-only Android smoke for SIS/DTIC Mobile APK artifacts.
# This script intentionally does NOT perform login, initSession, ticket reads,
# ticket creation, followups, attachments, status changes, solutions, DELETE,
# purge, or cleanup against GLPI. It only validates install, launch, empty-form
# validation, screenshots, package metadata, and crash absence.

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
ANDROID_HOME_DEFAULT="/home/jonathan/Android/Sdk"
ANDROID_HOME="${ANDROID_HOME:-$ANDROID_HOME_DEFAULT}"
ADB="$ANDROID_HOME/platform-tools/adb"
EMULATOR="$ANDROID_HOME/emulator/emulator"
AAPT="$ANDROID_HOME/build-tools/36.0.0/aapt"
AVD_NAME="${AVD_NAME:-hermes_sis_mobile_api35}"
ANDROID_AVD_HOME="${ANDROID_AVD_HOME:-/home/jonathan/.android/avd}"
OUT_DIR="${OUT_DIR:-/home/jonathan/.brain/evidence/sis-mobile/android-smoke-$(date +%Y%m%d-%H%M%S)}"
SIS_APK="${SIS_APK:-/mnt/c/Users/jonathan-moletta/ops/sis-mobile/sis-mobile-release-worker-status-rules-public-20260518.apk}"
DTIC_APK="${DTIC_APK:-/mnt/c/Users/jonathan-moletta/ops/dtic-mobile/dtic-mobile-release-worker-status-rules-public-20260518.apk}"
ALLOW_KVM_CHMOD=0
KEEP_EMULATOR=0
SERIAL=""
EMULATOR_SESSION_STARTED=0
EMULATOR_PID=""
KVM_ORIGINAL_MODE=""

usage() {
  cat <<'USAGE'
Usage: tool/android/readonly_smoke_android.sh [--allow-kvm-chmod] [--keep-emulator]

Environment overrides:
  ANDROID_HOME       Android SDK root (default: /home/jonathan/Android/Sdk)
  AVD_NAME           AVD name (default: hermes_sis_mobile_api35)
  ANDROID_AVD_HOME   AVD directory (default: /home/jonathan/.android/avd)
  SIS_APK            SIS APK path
  DTIC_APK           DTIC APK path
  OUT_DIR            Evidence output directory

Safety:
  - No credentials are read or typed.
  - No GLPI login/initSession is executed.
  - No ticket/followup/attachment/status/solution mutation is executed.
  - Empty-form validation only.
USAGE
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --allow-kvm-chmod) ALLOW_KVM_CHMOD=1 ;;
    --keep-emulator) KEEP_EMULATOR=1 ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown arg: $1" >&2; usage; exit 2 ;;
  esac
  shift
done

log() { printf '[%s] %s\n' "$(date +%H:%M:%S)" "$*" | tee -a "$OUT_DIR/run.log"; }
run() { log "+ $*"; "$@" 2>&1 | tee -a "$OUT_DIR/run.log"; }

restore_kvm() {
  if [[ -n "$KVM_ORIGINAL_MODE" && -e /dev/kvm ]]; then
    sudo chmod "$KVM_ORIGINAL_MODE" /dev/kvm >/dev/null 2>&1 || true
  fi
}

cleanup() {
  restore_kvm
  if [[ "$KEEP_EMULATOR" != "1" && "$EMULATOR_SESSION_STARTED" == "1" ]]; then
    if [[ -n "$EMULATOR_PID" ]]; then
      kill "$EMULATOR_PID" >/dev/null 2>&1 || true
      sleep 2
      kill -9 "$EMULATOR_PID" >/dev/null 2>&1 || true
    fi
  fi
}
trap cleanup EXIT

mkdir -p "$OUT_DIR"

{
  echo "host=$(hostname)"
  echo "repo_root=$REPO_ROOT"
  echo "pwd=$(pwd)"
  echo "git_root=$(git -C "$REPO_ROOT" rev-parse --show-toplevel 2>/dev/null || true)"
  echo "branch=$(git -C "$REPO_ROOT" branch --show-current 2>/dev/null || true)"
  echo "path_class=WSL ext4 canonical project root under /home/jonathan/projects"
  echo "out_dir=$OUT_DIR"
  echo "sis_apk=$SIS_APK"
  echo "dtic_apk=$DTIC_APK"
  echo "avd_name=$AVD_NAME"
} | tee "$OUT_DIR/context.txt" >/dev/null

log "Starting read-only Android smoke. No GLPI credentials or mutations will be used."

for bin in "$ADB" "$EMULATOR" "$AAPT"; do
  [[ -x "$bin" ]] || { echo "Missing executable: $bin" >&2; exit 3; }
done
for apk in "$SIS_APK" "$DTIC_APK"; do
  [[ -f "$apk" ]] || { echo "Missing APK: $apk" >&2; exit 3; }
  sha256sum "$apk" | tee -a "$OUT_DIR/apk-sha256.txt"
  unzip -tq "$apk"
  "$AAPT" dump badging "$apk" | grep -E "^package:|^sdkVersion:|^targetSdkVersion:|^application-label:'" | head -8 | tee -a "$OUT_DIR/apk-badging.txt"
  for env_asset in assets/flutter_assets/.env assets/flutter_assets/.env.public; do
    unzip -p "$apk" "$env_asset" 2>/dev/null \
      | grep -E '^(GLPI_BASE_URL|SIS_GLPI_BASE_URL|SIS_METADATA_CATALOG_URL|DTIC_GLPI_BASE_URL|GLPI_DEBUG_LOGS|DTIC_ENABLE_FORM_SUBMISSION|DTIC_ENABLE_TICKET_ACTIONS)' \
      | sed "s#^#$env_asset:#" \
      | tee -a "$OUT_DIR/apk-public-env.txt" || true
  done
  echo >> "$OUT_DIR/apk-badging.txt"
  echo >> "$OUT_DIR/apk-public-env.txt"
done

if [[ -e /dev/kvm ]]; then
  KVM_ORIGINAL_MODE="$(stat -c '%a' /dev/kvm)"
  log "Current /dev/kvm mode: $KVM_ORIGINAL_MODE"
  if [[ ! -r /dev/kvm || ! -w /dev/kvm ]]; then
    if [[ "$ALLOW_KVM_CHMOD" == "1" ]]; then
      log "Temporarily enabling current-user KVM access via sudo chmod o+rw /dev/kvm; will restore on exit."
      sudo chmod o+rw /dev/kvm
    else
      log "KVM not readable/writable. Re-run with --allow-kvm-chmod if approved."
      exit 4
    fi
  fi
fi

run "$ADB" start-server
if ! HOME=/home/jonathan ANDROID_AVD_HOME="$ANDROID_AVD_HOME" "$EMULATOR" -list-avds | grep -qx "$AVD_NAME"; then
  log "AVD not found: $AVD_NAME"
  exit 5
fi

if ! "$ADB" devices | awk 'NR>1 && $2=="device"{found=1} END{exit !found}'; then
  log "Starting headless emulator $AVD_NAME"
  HOME=/home/jonathan ANDROID_AVD_HOME="$ANDROID_AVD_HOME" \
    "$EMULATOR" -avd "$AVD_NAME" -no-window -no-audio -no-snapshot -gpu swiftshader_indirect -wipe-data \
    >"$OUT_DIR/emulator.log" 2>&1 &
  EMULATOR_PID=$!
  EMULATOR_SESSION_STARTED=1
fi

for _ in $(seq 1 180); do
  SERIAL="$($ADB devices | awk 'NR>1 && $2=="device"{print $1; exit}')"
  [[ -n "$SERIAL" ]] && break
  sleep 2
done
[[ -n "$SERIAL" ]] || { log "No Android device became ready."; exit 6; }

for _ in $(seq 1 240); do
  boot="$($ADB -s "$SERIAL" shell getprop sys.boot_completed 2>/dev/null | tr -d '\r' || true)"
  [[ "$boot" == "1" ]] && break
  sleep 2
done
boot="$($ADB -s "$SERIAL" shell getprop sys.boot_completed | tr -d '\r')"
[[ "$boot" == "1" ]] || { log "Device did not complete boot."; exit 7; }

{
  echo "serial=$SERIAL"
  echo "boot_completed=$boot"
  "$ADB" -s "$SERIAL" shell wm size
  "$ADB" -s "$SERIAL" shell getprop ro.build.version.release
} | tee "$OUT_DIR/device.txt"

"$ADB" -s "$SERIAL" shell settings put global window_animation_scale 0 || true
"$ADB" -s "$SERIAL" shell settings put global transition_animation_scale 0 || true
"$ADB" -s "$SERIAL" shell settings put global animator_duration_scale 0 || true

run "$ADB" -s "$SERIAL" install -r "$SIS_APK"
run "$ADB" -s "$SERIAL" install -r "$DTIC_APK"
"$ADB" -s "$SERIAL" shell pm list packages | grep -E 'br.gov.rs.casacivil.(sis|dtic)mobile' | tee "$OUT_DIR/packages.txt"
"$ADB" -s "$SERIAL" shell dumpsys package br.gov.rs.casacivil.sismobile | grep -E 'Package \[|versionName|versionCode|firstInstallTime|lastUpdateTime' > "$OUT_DIR/sis-package-dumpsys.txt" || true
"$ADB" -s "$SERIAL" shell dumpsys package br.gov.rs.casacivil.dticmobile | grep -E 'Package \[|versionName|versionCode|firstInstallTime|lastUpdateTime' > "$OUT_DIR/dtic-package-dumpsys.txt" || true

# SIS launch and local empty-form validation.
"$ADB" -s "$SERIAL" logcat -c
"$ADB" -s "$SERIAL" shell monkey -p br.gov.rs.casacivil.sismobile -c android.intent.category.LAUNCHER 1 | tee -a "$OUT_DIR/run.log"
sleep 8
"$ADB" -s "$SERIAL" exec-out screencap -p > "$OUT_DIR/sis-login.png"
"$ADB" -s "$SERIAL" shell input tap 540 1775
sleep 2
"$ADB" -s "$SERIAL" exec-out screencap -p > "$OUT_DIR/sis-empty-login-validation.png"
"$ADB" -s "$SERIAL" logcat -d -t 1200 > "$OUT_DIR/sis-logcat-tail.txt"
"$ADB" -s "$SERIAL" shell am force-stop br.gov.rs.casacivil.sismobile || true

# DTIC launch and local empty-form validation.
"$ADB" -s "$SERIAL" logcat -c
"$ADB" -s "$SERIAL" shell monkey -p br.gov.rs.casacivil.dticmobile -c android.intent.category.LAUNCHER 1 | tee -a "$OUT_DIR/run.log"
sleep 8
"$ADB" -s "$SERIAL" exec-out screencap -p > "$OUT_DIR/dtic-login.png"
"$ADB" -s "$SERIAL" shell input tap 540 1740
sleep 2
"$ADB" -s "$SERIAL" exec-out screencap -p > "$OUT_DIR/dtic-empty-login-validation.png"
"$ADB" -s "$SERIAL" logcat -d -t 1200 > "$OUT_DIR/dtic-logcat-tail.txt"

if grep -E 'FATAL EXCEPTION|Force finishing|Fatal signal' "$OUT_DIR"/*-logcat-tail.txt >/dev/null; then
  log "Crash signature found in logcat. See $OUT_DIR/*-logcat-tail.txt"
  exit 8
fi

cat > "$OUT_DIR/summary.txt" <<EOF
READ-ONLY ANDROID SMOKE PASSED
No credentials used.
No GLPI login/initSession executed.
No ticket/followup/attachment/status/solution/DELETE/purge/cleanup executed.
SIS and DTIC installed and launched.
Empty-form validation screenshots captured.
No FATAL EXCEPTION / Force finishing / Fatal signal found in captured app logcat tails.
EOF

find "$OUT_DIR" -maxdepth 1 -type f -printf '%f %s bytes\n' | sort | tee "$OUT_DIR/files.txt"
log "Read-only Android smoke completed: $OUT_DIR"
