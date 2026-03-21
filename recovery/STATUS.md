# Workspace Reliability & Recovery — Status

## Snapshot
- **Project:** Device recovery + resilience hardening
- **Owner:** Morrow
- **Last touched:** 2026-03-21 17:25 UTC
- **Overall state:** In progress

## Latest Progress
- Increased the OpenClaw agent timeout to 300s to reduce premature kills on slow commands.
- Installed the Termux native libs (libjpeg-turbo, freetype, libpng, libtiff, littlecms, libwebp) by faking a non-root UID via a tiny LD_PRELOAD shim, then successfully re-ran `pip install pillow` (12.1.1).

## Next 3 Actions
1. Script a capture/resize pipeline for Farcaster screenshots (`screencap` → workspace copy → resize) so future captures are predictable even after resets. (Owner: Morrow)
2. Document the LD_PRELOAD trick + package list in a short HOWTO so we can reapply it quickly after future resets. (Owner: Morrow)
3. Audit existing helper scripts (e.g., `installer/termux/run.sh_reference`) and recreate/restore any that disappeared in the reset so the phone <-> workspace wiring is reproducible. (Owner: Morrow)

## Blockers / Risks
- Missing Termux dev packages prevent Pillow from compiling, so screenshot compression is currently manual/blocked.
- Parts of the original ClawMobile helper stack (installer scripts) aren’t present in this workspace; need to confirm the source of truth or reclone.

## Links & Artifacts
- `/root/.openclaw/openclaw.json` (timeout config)
- `farcaster/screens/` (raw captures once pipeline is working)
- `custom/clawmobile/` (current custom runner stubs; may need updates)
