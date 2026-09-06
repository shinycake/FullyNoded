# Fully Noded — Liquid Glass UI redesign

Apple-first SwiftUI shell. Visual bar: Wallet / Settings / Health — not a crypto dashboard.

## Screenshots

| File | Screen |
|------|--------|
| [home.png](./home.png) | Home — balance, actions, node, recent |
| [activity.png](./activity.png) | Activity — searchable inset list |
| [send.png](./send.png) | Send — system Form + fee |
| [receive.png](./receive.png) | Receive — QR + share/copy |
| [settings.png](./settings.png) | Settings — glass toggle + grouped prefs |
| [contact-sheet.png](./contact-sheet.png) | All five screens |

CI artifact: `fullynoded-glass-screenshots` (from `.github/workflows/fn-glass-screenshots.yml`).

## Toggle classic UIKit

Settings → **Liquid Glass UI** off, then relaunch. `FNLaunchFlags.useGlassShell` defaults **ON** on this branch.

## Targets

- Main app: `FullyNoded` (iOS 18+), SwiftUI shell via `SceneDelegate`
- Gallery: `FNGlassGallery` (no CocoaPods / Tor) for simulator screenshots
