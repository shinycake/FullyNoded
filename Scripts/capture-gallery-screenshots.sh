#!/usr/bin/env bash
# Build FNGlassGallery and capture Liquid Glass screenshots.
# REQUIRES Xcode with Swift 6.2+ (compiler glass symbols) AND an iOS 26+ Simulator runtime.
# Material/capsule fallbacks must NOT be published as Liquid Glass.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OUT_DOCS="${OUT_DOCS:-$ROOT/Docs/ui-redesign}"
OUT_ART="${OUT_ART:-$ROOT/artifacts/ui-screenshots}"
DERIVED="${DERIVED:-$ROOT/build/DerivedData}"
BUNDLE_ID="com.shinycake.FNGlassGallery"
SCHEME="FNGlassGallery"
PROJECT="$ROOT/FNGlassGallery.xcodeproj"

mkdir -p "$OUT_DOCS" "$OUT_ART"

echo "==> Locating Xcode with iOS 26 / Swift 6.2 glass support"
select_xcode() {
  local candidates=()
  local found
  while IFS= read -r found; do
    candidates+=("$found")
  done < <(ls -d /Applications/Xcode*.app 2>/dev/null || true)

  local best=""
  local best_score=-1
  for app in "${candidates[@]}"; do
    [[ -d "$app" ]] || continue
    local ver major score=0
    ver="$(DEVELOPER_DIR="$app/Contents/Developer" xcodebuild -version 2>/dev/null | awk '/Xcode/{print $2}' || true)"
    [[ -n "$ver" ]] || continue
    major="${ver%%.*}"
    score=$major
    # Prefer beta when majors tie (often ships newer SDK first)
    if [[ "$app" == *beta* ]] || [[ "$app" == *Beta* ]]; then
      score=$((score + 1))
    fi
    if (( score > best_score )); then
      best="$app"
      best_score=$score
    fi
  done

  if [[ -z "$best" ]]; then
    echo "ERROR: No Xcode installation found under /Applications." >&2
    exit 1
  fi
  export DEVELOPER_DIR="$best/Contents/Developer"
  sudo xcode-select -s "$DEVELOPER_DIR" 2>/dev/null || true
  echo "Using Xcode: $best"
  xcodebuild -version
}

select_xcode

XCODE_MAJOR="$(xcodebuild -version | awk '/Xcode/{print $2}' | cut -d. -f1)"
if [[ -z "$XCODE_MAJOR" ]] || (( XCODE_MAJOR < 26 )); then
  cat >&2 <<EOF
ERROR: Xcode ${XCODE_MAJOR:-unknown} is too old for Liquid Glass compile-time APIs.

FNGlass gates .glassEffect / .buttonStyle(.glass) behind \`#if compiler(>=6.2)\`
(Xcode 26+). Building with older Xcode silently compiles material fallbacks only.

Install Xcode 26+ (or the current beta that ships the iOS 26 SDK) and re-run.
EOF
  exit 2
fi

echo "==> Available runtimes:"
xcrun simctl list runtimes || true

echo "==> Selecting iOS 26+ simulator runtime"
IOS26_RUNTIME=""
IOS26_LABEL=""
while IFS= read -r line; do
  if [[ "$line" =~ iOS[[:space:]]+(2[6-9]|[3-9][0-9])(\.[0-9]+)* ]]; then
    rid="$(echo "$line" | grep -oE 'com\.apple\.CoreSimulator\.SimRuntime\.iOS-[0-9-]+' | head -1 || true)"
    if [[ -n "$rid" ]]; then
      IOS26_RUNTIME="$rid"
      IOS26_LABEL="$line"
      echo "Found runtime: $line"
      break
    fi
  fi
done < <(xcrun simctl list runtimes)

if [[ -z "$IOS26_RUNTIME" ]]; then
  cat >&2 <<'EOF'
ERROR: No iOS 26+ Simulator runtime is installed.

Liquid Glass only renders on iOS 26+. Capturing on iOS 18 would silently produce
opaque material/capsule fallbacks and must not be published as glass screenshots.

Fix:
  1. Install Xcode 26+ (or current beta with iOS 26 SDK)
  2. Xcode → Settings → Platforms → download iOS 26.x Simulator
  3. Re-run this script / workflow
EOF
  exit 2
fi

# Prefer iPhone 16 on that runtime; create one if needed.
DEVICE_TYPE="com.apple.CoreSimulator.SimDeviceType.iPhone-16"
DEVICE_NAME="FN Glass iPhone 16"
UDID="$(xcrun simctl list devices available | awk -v rt="$IOS26_RUNTIME" '
  index($0, rt) {inrt=1; next}
  /^--/ {inrt=0}
  inrt && /iPhone 16 \(/ {
    if (match($0, /\(([A-F0-9-]{36})\)/)) { print substr($0, RSTART+1, RLENGTH-2); exit }
  }
')"

if [[ -z "${UDID:-}" ]]; then
  echo "Creating simulator '$DEVICE_NAME' on $IOS26_RUNTIME"
  UDID="$(xcrun simctl create "$DEVICE_NAME" "$DEVICE_TYPE" "$IOS26_RUNTIME" 2>/dev/null || true)"
fi

if [[ -z "${UDID:-}" ]]; then
  UDID="$(xcrun simctl list devices available | awk -v rt="$IOS26_RUNTIME" '
    index($0, rt) {inrt=1; next}
    /^--/ {inrt=0}
    inrt && /iPhone/ {
      if (match($0, /\(([A-F0-9-]{36})\)/)) { print substr($0, RSTART+1, RLENGTH-2); exit }
    }
  ')"
fi

if [[ -z "${UDID:-}" ]]; then
  echo "ERROR: Could not find or create an iPhone simulator for $IOS26_RUNTIME" >&2
  xcrun simctl list devices available >&2 || true
  exit 2
fi

DESTINATION="platform=iOS Simulator,id=$UDID"
echo "Simulator UDID=$UDID"
echo "Runtime: $IOS26_LABEL"
echo "Destination: $DESTINATION"

echo "==> Booting simulator"
xcrun simctl boot "$UDID" 2>/dev/null || true
xcrun simctl bootstatus "$UDID" -b

# Reuse existing build if APP already present under DERIVED (CI builds first)
APP="$(find "$DERIVED/Build/Products" -name 'FNGlassGallery.app' -type d 2>/dev/null | head -1 || true)"
if [[ -z "$APP" ]]; then
  echo "==> Building $SCHEME for iOS 26 simulator"
  xcodebuild \
    -project "$PROJECT" \
    -scheme "$SCHEME" \
    -destination "$DESTINATION" \
    -derivedDataPath "$DERIVED" \
    -configuration Debug \
    build \
    CODE_SIGNING_ALLOWED=NO \
    CODE_SIGN_IDENTITY="" \
    CODE_SIGNING_REQUIRED=NO
  APP="$(find "$DERIVED/Build/Products" -name 'FNGlassGallery.app' -type d | head -1)"
fi

if [[ -z "$APP" ]]; then
  echo "ERROR: FNGlassGallery.app not found under $DERIVED" >&2
  exit 1
fi
echo "App: $APP"

echo "==> Installing"
xcrun simctl uninstall "$UDID" "$BUNDLE_ID" 2>/dev/null || true
xcrun simctl install "$UDID" "$APP"

declare -a SCREENS=(home activity send receive settings)

capture_screen() {
  local screen="$1"
  echo "==> Capturing $screen → ${screen}.png"
  xcrun simctl terminate "$UDID" "$BUNDLE_ID" 2>/dev/null || true
  xcrun simctl launch "$UDID" "$BUNDLE_ID" "-FNGalleryScreen" "$screen"
  sleep 2.8
  xcrun simctl io "$UDID" screenshot "$OUT_DOCS/${screen}.png"
  cp "$OUT_DOCS/${screen}.png" "$OUT_ART/${screen}.png"
}

for screen in "${SCREENS[@]}"; do
  capture_screen "$screen"
done

echo "==> Building contact sheet from captures"
python3 - <<'PY' "$OUT_DOCS" "$OUT_ART"
import sys
from pathlib import Path

docs, art = Path(sys.argv[1]), Path(sys.argv[2])
names = ["home", "activity", "send", "receive", "settings"]
try:
    from PIL import Image, ImageDraw, ImageFont
except ImportError:
    # Fallback: copy home as placeholder and warn
    src = docs / "home.png"
    for dest in (docs / "contact-sheet.png", art / "contact-sheet.png", docs / "sheet.png", art / "sheet.png"):
        dest.write_bytes(src.read_bytes())
    print("WARN: Pillow missing — contact sheet is a home duplicate", file=sys.stderr)
    raise SystemExit(0)

imgs = [Image.open(docs / f"{n}.png").convert("RGB") for n in names]
w, h = imgs[0].size
pad, label_h, gap = 24, 36, 16
cols, rows = 3, 2
sheet_w = pad * 2 + cols * w + (cols - 1) * gap
sheet_h = pad * 2 + rows * (h + label_h) + (rows - 1) * gap + 48
sheet = Image.new("RGB", (sheet_w, sheet_h), (18, 18, 20))
draw = ImageDraw.Draw(sheet)
try:
    font = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", 22)
    title_font = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", 28)
except Exception:
    font = ImageFont.load_default()
    title_font = font
draw.text((pad, 14), "Fully Noded — Liquid Glass (iOS 26 gallery)", fill=(240, 240, 245), font=title_font)

for i, (name, im) in enumerate(zip(names, imgs)):
    r, c = divmod(i, cols)
    x = pad + c * (w + gap)
    y = 48 + pad + r * (h + label_h + gap)
    draw.text((x, y), name.title(), fill=(200, 200, 210), font=font)
    sheet.paste(im, (x, y + label_h))

for dest in (docs / "contact-sheet.png", art / "contact-sheet.png", docs / "sheet.png", art / "sheet.png"):
    sheet.save(dest, "PNG")
print(f"Wrote contact sheet {sheet.size[0]}x{sheet.size[1]}")
PY

# Provenance sidecar for PR summary
{
  echo "xcode=$(xcodebuild -version | tr '\n' ' ')"
  echo "runtime=$IOS26_RUNTIME"
  echo "runtime_label=$IOS26_LABEL"
  echo "udid=$UDID"
  echo "destination=$DESTINATION"
} | tee "$OUT_ART/capture-provenance.txt"
cp "$OUT_ART/capture-provenance.txt" "$OUT_DOCS/capture-provenance.txt"

echo "==> Screenshots written"
ls -la "$OUT_DOCS"/*.png
echo "Xcode major=$XCODE_MAJOR · runtime=$IOS26_RUNTIME"
