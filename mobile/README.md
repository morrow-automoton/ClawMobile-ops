# Mobile Control Helper

This directory holds the helper entry points for the ClawMobile setup.

## Key Files

- `manage.sh` → symlink to `installer/ubuntu/mobile-runner.sh`. Use this for all in-VM maintenance.
- `README.md` → (this file) quick reference so I don’t have to remember the commands.

## Start-up Flow

1. **Termux (host side)**
   - Run `./installer/termux/run.sh` to bring up OpenClaw. This script now only selects the DroidRun provider, writes an env file, and calls the runner inside Ubuntu.
   - The legacy script is kept at `./installer/termux/run.sh_reference` just in case.

2. **Inside Ubuntu (my side)**
   - Use `/root/.openclaw/workspace/mobile/manage.sh <command>` for everything else.

## manage.sh Commands

- `start-gateway` – prep the phone stack and launch `openclaw gateway` (blocks).
- `restart-gateway` – stop any running gateway and relaunch (will briefly drop the chat).
- `prep-phone` – rebuild/install the mobile plugin, refresh adb selection, sync workspace seeds, apply the Telegram IME command, and rerun Tailscale Serve without touching the gateway.
- `tailscale-ensure` – make sure `tailscaled` is running (userspace networking) and reapply `tailscale serve --bg --yes ${GATEWAY_PORT}`.
- `adb-refresh` – rerun the adb auto-pick logic.
- `onboard [args]` – run `openclaw onboard --skip-daemon [args]` so I can reconfigure skills/channels with permission.

## Supporting Files
## Custom ClawMobile overrides

- Custom scripts live under `/root/.openclaw/workspace/custom/clawmobile`.
- Actual files inside `/data/data/com.termux/files/home/ClawMobile/installer/...` are symlinks back to those custom copies (currently `termux/run.sh`, `termux/onboard.sh`, and `ubuntu/mobile-runner.sh`).
- ClawMobile repo commit in use: `81c93442abada83c9b1f0e1190c823dd68510463`. Recreating the setup = clone that commit, then re-create the symlinks or run `ln -s /root/.openclaw/workspace/custom/clawmobile/...`.
- Track/update the custom files via a separate git repo in `/root/.openclaw/workspace`; keep the upstream ClawMobile repo clean (use `git update-index --skip-worktree` on the symlinked paths if needed).

## Supporting Files

- Cached DroidRun env: `/root/.openclaw/mobile/droidrun.env`
- Runner implementation: `/data/data/com.termux/files/home/ClawMobile/installer/ubuntu/mobile-runner.sh`
- Termux wrappers: `installer/termux/run.sh` and `installer/termux/onboard.sh`

## Tailscale Notes

- `manage.sh` will start `tailscaled` in userspace-networking mode if it isn’t already running.
- `tailscale serve` is now enabled for this tailnet; the helper will proxy 127.0.0.1:18789 to `https://morrow.tailf8ce5a.ts.net/` whenever `prep-phone`/`tailscale-ensure` runs.

## Usage Tips

- Always ask before running `onboard` or `restart-gateway`; both affect Matt’s active session.
- After any Termux reboot, Matt just needs to run `./installer/termux/run.sh`; once the gateway is up, everything else can be managed via this directory.
