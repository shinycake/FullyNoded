#!/usr/bin/env bash
# Local / CI helper: render Apple-first HTML previews to PNG via headless Chrome.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
HTML="$ROOT/Docs/ui-redesign/preview.html"
OUT_DOCS="$ROOT/Docs/ui-redesign"
OUT_ART="$ROOT/artifacts/ui-screenshots"
OUT_CURSOR="/opt/cursor/artifacts"
mkdir -p "$OUT_DOCS" "$OUT_ART" "$OUT_CURSOR"

CHROME=$(command -v google-chrome || command -v chromium || command -v chromium-browser || true)
if [[ -z "$CHROME" ]]; then
  echo "Chrome not found" >&2
  exit 1
fi

SCREENS=(home activity send receive settings)
for s in "${SCREENS[@]}"; do
  "$CHROME" --headless --disable-gpu --hide-scrollbars \
    --window-size=390,844 \
    --screenshot="$OUT_DOCS/${s}.png" \
    "file://${HTML}?screen=${s}" \
    2>/dev/null
  cp "$OUT_DOCS/${s}.png" "$OUT_ART/${s}.png"
  cp "$OUT_DOCS/${s}.png" "$OUT_CURSOR/${s}.png"
  echo "Wrote ${s}.png"
done

# Contact sheet
"$CHROME" --headless --disable-gpu --hide-scrollbars \
  --window-size=1280,900 \
  --screenshot="$OUT_DOCS/contact-sheet.png" \
  "file://${HTML}?screen=sheet" \
  2>/dev/null
cp "$OUT_DOCS/contact-sheet.png" "$OUT_ART/contact-sheet.png"
cp "$OUT_DOCS/contact-sheet.png" "$OUT_CURSOR/contact-sheet.png"

ls -la "$OUT_DOCS"
