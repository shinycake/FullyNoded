# Fully Noded — SwiftUI glass design spike (opt-in / gallery)

This is a **design spike**, not the production shell.

- **Default app launch:** classic UIKit / Main storyboard
- **Glass UI:** `FNGlassGallery` (demo data) or Settings → **Liquid Glass UI (opt-in)** + relaunch
- Screens use **demo balances, demo node, and a BIP173 example receive address** until live wallet/node bindings exist
- Receive Copy/Share and Send “Create PSBT” are **disabled** and marked Demo in the glass shell
- Security rows are non-navigable Demo placeholders (no chevrons)
- Liquid Glass APIs are gated to iOS 26 with material fallbacks — surface area is intentionally thin

## Screenshots

| File | Screen |
|------|--------|
| [home.png](./home.png) | Home — demo banner, balance, actions |
| [activity.png](./activity.png) | Activity — searchable inset list |
| [send.png](./send.png) | Send — demo form, PSBT disabled |
| [receive.png](./receive.png) | Receive — real CI QR + DEMO watermark, Copy/Share off |
| [settings.png](./settings.png) | Settings — opt-in toggle |
| [contact-sheet.png](./contact-sheet.png) | Contact sheet |

CI artifact: **`fullynoded-glass-screenshots`** (PR / manual workflow only).

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
open FNGlassGallery.xcodeproj   # always shows glass + demo data
pod install && open FullyNoded.xcworkspace  # classic by default
```
