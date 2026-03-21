#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

UBUNTU_DISTRO="${UBUNTU_DISTRO:-ubuntu}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
RUNNER_SCRIPT="${REPO_ROOT}/installer/ubuntu/mobile-runner.sh"

ONBOARD_ARGS=""
for arg in "$@"; do
  ONBOARD_ARGS+=" $(printf '%q' "$arg")"
done

echo "[clawbot] Entering Ubuntu and starting OpenClaw onboard..."
echo "[clawbot] When you see 'Onboard complete', press Ctrl+C to exit onboard if it does not."
echo

if [ ! -x "$RUNNER_SCRIPT" ]; then
  echo "[clawbot] ERROR: runner script not found at $RUNNER_SCRIPT" >&2
  exit 1
fi

proot-distro login "${UBUNTU_DISTRO}" --shared-tmp -- bash -lc 'bash -seuo pipefail' <<EOF
exec '${RUNNER_SCRIPT}' onboard${ONBOARD_ARGS}
EOF
