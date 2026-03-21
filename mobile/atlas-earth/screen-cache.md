# Atlas Earth Screen Cache

## Popup: Atlas Arcade IAM
- **Detection clues:** `android.app.AlertDialog` inside a `WebView`, title "Atlas Arcade" with CTA button "Open Arcade to Start Earning!" and a close button labeled `✕` in the top-right corner.
- **Bounds (1080x2400 device):** close button `[880,410][1001,531]` → safe tap center `(940,470)`.
- **Action:** tap the `✕` button to dismiss; ignore the CTA unless we actually want to open Arcade.
- **Notes:** treat as promo; appears on app launch. Cache this so future automation can immediately close it.
