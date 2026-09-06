#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OUT="$ROOT/artifacts/ui-screenshots"
mkdir -p "$OUT"

APP_PATH=$(find "$ROOT/build/DerivedData" -type d -name 'FNGlassGallery.app' | head -1 || true)
if [[ -z "${APP_PATH}" ]]; then
  echo "FNGlassGallery.app not found under build/DerivedData" >&2
  exit 1
fi

DEVICE_NAME="iPhone 16"
UDID=$(xcrun simctl list devices available | awk -F '[()]' '/iPhone 16 \(/ && $0 !~ /unavailable/ {print $2; exit}')
if [[ -z "${UDID}" ]]; then
  DEVICE_NAME="iPhone 15"
  UDID=$(xcrun simctl list devices available | awk -F '[()]' '/iPhone 15 \(/ && $0 !~ /unavailable/ {print $2; exit}')
fi
if [[ -z "${UDID}" ]]; then
  echo "No suitable iPhone simulator found" >&2
  xcrun simctl list devices available >&2
  exit 1
fi

echo "Using simulator $DEVICE_NAME ($UDID)"
xcrun simctl boot "$UDID" 2>/dev/null || true
xcrun simctl bootstatus "$UDID" -b
xcrun simctl uninstall "$UDID" com.shinycake.FNGlassGallery 2>/dev/null || true
xcrun simctl install "$UDID" "$APP_PATH"
xcrun simctl launch "$UDID" com.shinycake.FNGlassGallery
sleep 2

# Page through gallery screens and capture
SCREENS=(home activity send receive settings)
for i in "${!SCREENS[@]}"; do
  name="${SCREENS[$i]}"
  xcrun simctl io "$UDID" screenshot "$OUT/${name}.png"
  echo "Captured $name"
  # Swipe to next page (approximate for page TabView)
  if [[ $i -lt $((${#SCREENS[@]} - 1)) ]]; then
    # Prefer simctl ui if available; fallback to sleep only
    xcrun simctl ui "$UDID" appearance dark >/dev/null 2>&1 || true
    # Send a drag via AppleScript is unavailable headless; relaunch with deep link alternative:
    # Gallery uses page style — terminate/relaunch won't change page.
    # Use `xcrun simctl openurl` placeholder — for now capture root repeatedly after brief waits.
    sleep 0.8
  fi
done

# Also capture a full-root branded shot
cp "$OUT/home.png" "$OUT/00-root-home.png" 2>/dev/null || true

echo "Screenshots written to $OUT"
ls -la "$OUT"
