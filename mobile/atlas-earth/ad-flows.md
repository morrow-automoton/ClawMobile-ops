# Atlas Earth Ad Flows

## Flow 1 – Video ad + Galaxy Store
- **Duration:** ~15–30 seconds video.
- **Sequence:**
  1. Watch video. No skip timer.
  2. When the overlay with "Store" text appears in the top-left (screen `Screenshot_20260320-200906_Atlas Earth.jpg`), tap the store link to advance.
  3. Galaxy Store modal opens (`Screenshot_20260320-201049_Galaxy Store.jpg`). Use the Android back button (`adb shell input keyevent KEYCODE_BACK`) to dismiss.
  4. Wait 1–2 seconds for the `✕` close icon to appear in the top-right of the ad (`Screenshot_20260320-201118_Atlas Earth.jpg`). Tap it (with ±70px jitter) to exit the ad.
  5. Boost modal closes; the map shows a countdown timer under the header. First boost sets ~1h, each boost adds +1h up to 6h. Above 5h remaining, boosts are disabled.
- **Notes:** Some creatives briefly flash an unusable skip/close icon for a frame—ignore; only tap controls that stay visible for >1s.

## Flow 2 – Video ad (container B)
- **Screens:** `Screenshot_20260320-203909` → `203921` → `204043` → `204059_Galaxy Store` → `204112` → `204131` → `204141`.
- **Behavior:** Same pattern as Flow 1. Watch 15–30 s, tap the “Store” link in the top-left overlay (visible in `204043`), back out of the Galaxy Store modal (`204059`), wait ~1 s for the `✕` to stabilize (`204112`), then tap to exit (`204131`/`204141`).

## Flow 3 – Video ad (container C)
- **Screens:** `Screenshot_20260320-204255` → `204309_Galaxy Store` → `204326` (etc.).
- **Behavior:** Identical container: video → “Store” overlay near top-left → Galaxy Store modal → Android back → wait 1–2 s → tap `✕` in the same top-right quadrant.

## Flow 4 – TikTok-style ad (triangle skip)
- **Screens:** `Screenshot_20260320-210407` → `210451` → `210512` → `210531`.
- **Behavior:**
  1. Video shows an `✕` inside the creative—ignore it (it just opens TikTok).
  2. After ~15 s a real “skip” control (triangle + vertical bar) appears much closer to the top-right corner than the in-ad `✕`.
  3. Tap the triangle to advance to the reward screen.
  4. Boost modal closes as usual.
- **Jitter:** treat the triangle’s bounding box as a tight 40×40 px area near the top-right corner.
