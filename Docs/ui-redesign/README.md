# Fully Noded — SwiftUI glass design spike (opt-in / gallery)

This is a **design spike**, not the production shell.

- **Default app launch:** classic UIKit / Main storyboard
- **Glass UI:** `FNGlassGallery` (demo data) or Settings → **Liquid Glass UI (opt-in)** + relaunch
- Screens use **demo balances, demo node, and a BIP173 example receive address** until live wallet/node bindings exist
- Receive Copy/Share and Send “Create PSBT” are **disabled** and marked Demo in the glass shell
- Security rows are non-navigable Demo placeholders (no chevrons)
- Liquid Glass APIs (`.glassEffect`, `.buttonStyle(.glass)`, `GlassEffectContainer`) are gated to **iOS 26 + Xcode 26 / Swift 6.2**; material/capsule fallbacks otherwise
- Glass is applied to **chrome + heroes + primary buttons** (balance, node, QR, fee, tab bar); content lists stay inset-style

## Screenshots

Captured on an **iOS 26** Simulator with Xcode 26+ (see `capture-provenance.txt` when present). Older OS captures are rejected by CI.

| File | Screen |
|------|--------|
| [home.png](./home.png) | Home — glass balance hero, glass Send/Receive, glass node card, system tab chrome |
| [activity.png](./activity.png) | Activity — glass search + list surface |
| [send.png](./send.png) | Send — glass form + fee card, Create PSBT disabled |
| [receive.png](./receive.png) | Receive — glass QR card, DEMO watermark, Copy/Share off |
| [settings.png](./settings.png) | Settings — glass sections, opt-in toggle |
| [contact-sheet.png](./contact-sheet.png) | Contact sheet of the above |

CI artifact: **`fullynoded-glass-screenshots`** (PR / manual workflow).

## Architecture

| Piece | Location |
|-------|----------|
| Tokens + selective glass | `FullyNoded/UI/DesignSystem/` |
| Demo models | `FullyNoded/UI/Models/` |
| Screens | `FullyNoded/UI/Screens/` |
| Tab root + host | `FullyNoded/UI/Shell/` |
| Gallery | `FNGlassGallery/` |

Deep links (PSBT / `.txn` / Coldcard / account-map) restore the classic tab-bar root when glass is active so presenters are not silent no-ops.

## Local

```bash
# Requires Xcode 26+ and an iOS 26 Simulator runtime
Scripts/capture-gallery-screenshots.sh

open FNGlassGallery.xcodeproj   # always shows glass + demo data (on iOS 26)
pod install && open FullyNoded.xcworkspace  # classic by default
```
