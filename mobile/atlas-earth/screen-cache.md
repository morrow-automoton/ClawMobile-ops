# Atlas Earth Screen Cache

## Popup: Atlas Arcade IAM
- **Detection clues:** `android.app.AlertDialog` inside a `WebView`, title "Atlas Arcade" with CTA button "Open Arcade to Start Earning!" and a close button labeled `✕` in the top-right corner.
- **Bounds (1080x2400 device):** close button `[880,410][1001,531]` → safe tap center `(940,470)`.
- **Action:** tap the `✕` button to dismiss; ignore the CTA unless we actually want to open Arcade.
- **Notes:** treat as promo; appears on app launch. Cache this so future automation can immediately close it.

## Popup: Play in-app review
- **Detection clues:** Standard Google Play review modal (stars + “Rate this app” UI). UI elements aren’t exposed via `uiautomator` on this build, so treat as opaque overlay.
- **Dismiss:** tap the close `✕` in the top-right corner (observed at ~ `(867,575)` on the 1080×2400 device). Add slight jitter within that 100×100px region to avoid bot-like taps.

## Overlay: Store CTA (top-left)
- **Detection:** Wide, shallow button near the top-left when ad finishes playback.
- **Jitter:** ±30 px horizontal, ±5 px vertical.
- **Action:** Tap once to trigger the Galaxy Store sheet; do not double-tap.
