# Workspace Reliability & Recovery — Status

## Snapshot
- **Project:** Device recovery + resilience hardening
- **Owner:** Morrow
- **Last touched:** 2026-03-21 17:25 UTC
- **Overall state:** In progress

## Latest Progress
- Increased the OpenClaw agent timeout to 300s to reduce premature kills on slow commands.
- Attempted to install Pillow for on-device image resizing; build failed because libjpeg headers aren’t present in Termux.

## Next 3 Actions
1. Install the native libs Termux needs for Pillow (`pkg install libjpeg-turbo freetype libpng libtiff littlecms libwebp zlib`) and retry `pip install pillow`. Document the exact steps + troubleshooting tips. (Owner: Morrow)
2. Script a capture/resize pipeline for Farcaster screenshots (`screencap` → workspace copy → resize) so future captures are predictable even after resets. (Owner: Morrow)
3. Audit existing helper scripts (e.g., `installer/termux/run.sh_reference`) and recreate/restore any that disappeared in the reset so the phone <-> workspace wiring is reproducible. (Owner: Morrow)

## Blockers / Risks
- Missing Termux dev packages prevent Pillow from compiling, so screenshot compression is currently manual/blocked.
- Parts of the original ClawMobile helper stack (installer scripts) aren’t present in this workspace; need to confirm the source of truth or reclone.

## Links & Artifacts
- `/root/.openclaw/openclaw.json` (timeout config)
- `farcaster/screens/` (raw captures once pipeline is working)
- `custom/clawmobile/` (current custom runner stubs; may need updates)
