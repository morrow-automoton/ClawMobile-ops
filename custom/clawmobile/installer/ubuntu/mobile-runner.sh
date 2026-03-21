#!/usr/bin/env bash
set -euo pipefail

COMMAND="${1:-start-gateway}"
shift || true

SOURCE="${BASH_SOURCE[0]}"
while [ -h "${SOURCE}" ]; do
  DIR="$(cd -P "$(dirname "${SOURCE}")" && pwd)"
  SOURCE="$(readlink "${SOURCE}")"
  [[ ${SOURCE} != /* ]] && SOURCE="${DIR}/${SOURCE}"
done
SCRIPT_DIR="$(cd -P "$(dirname "${SOURCE}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
PLUGIN_DIR="${PLUGIN_DIR:-${REPO_ROOT}/openclaw-plugin-mobile-ui}"
SEED_DIR="${REPO_ROOT}/installer/workspace-seed"
REPO_RULES="${REPO_ROOT}/memory"
WORKSPACE="${WORKSPACE:-/root/.openclaw/workspace}"
DROIDRUN_CACHE="${DROIDRUN_CACHE:-/root/.openclaw/mobile/droidrun.env}"
TMP_ENV="${TMP_ENV:-}"
GATEWAY_PORT="${GATEWAY_PORT:-18789}"
GATEWAY_BIND="${GATEWAY_BIND:-loopback}"
TAILSCALE_SOCKET="${TAILSCALE_SOCKET:-/run/tailscale/tailscaled.sock}"
TAILSCALE_STATE="${TAILSCALE_STATE:-/var/lib/tailscale/tailscaled.state}"
TAILSCALE_LOG="${TAILSCALE_LOG:-/var/lib/tailscale/tailscaled.log}"
TAILSCALE_SOCKS="${TAILSCALE_SOCKS:-localhost:1055}"
TAILSCALE_HTTP="${TAILSCALE_HTTP:-localhost:1056}"

mkdir -p "$(dirname "${DROIDRUN_CACHE}")" || true
mkdir -p "${WORKSPACE}" || true

log() {
  echo "[mobile-runner][$COMMAND] $*"
}

source_env_patch() {
  if [ -f "${REPO_ROOT}/installer/ubuntu/env.sh" ]; then
    # shellcheck disable=SC1091
    source "${REPO_ROOT}/installer/ubuntu/env.sh"
    log "loaded env patch"
  fi
}

activate_python() {
  if [ -f "/root/venvs/clawbot/bin/activate" ]; then
    # shellcheck disable=SC1091
    source "/root/venvs/clawbot/bin/activate"
    if [ -x "/root/venvs/clawbot/bin/python3" ]; then
      export CLAW_MOBILE_PYTHON="/root/venvs/clawbot/bin/python3"
    else
      export CLAW_MOBILE_PYTHON="/root/venvs/clawbot/bin/python"
    fi
  else
    log "WARNING: /root/venvs/clawbot not found; defaulting to system python"
  fi
  log "CLAW_MOBILE_PYTHON=${CLAW_MOBILE_PYTHON:-<unset>}"
}

import_droidrun_env() {
  local env_source=""

  if [ -n "${TMP_ENV}" ] && [ -f "${TMP_ENV}" ]; then
    env_source="${TMP_ENV}"
  elif [ -f "${DROIDRUN_CACHE}" ]; then
    env_source="${DROIDRUN_CACHE}"
  fi

  if [ -n "${env_source}" ]; then
    # shellcheck disable=SC1090
    source "${env_source}"
    if [ "${env_source}" != "${DROIDRUN_CACHE}" ]; then
      cp "${env_source}" "${DROIDRUN_CACHE}"
      chmod 600 "${DROIDRUN_CACHE}" || true
      log "cached droidrun env at ${DROIDRUN_CACHE}"
    fi
  fi

  log "droidrun provider=${DROIDRUN_PROVIDER:-<empty>} model=${DROIDRUN_MODEL:-<empty>}"
}

ensure_tailscaled() {
  if pgrep -x tailscaled >/dev/null 2>&1; then
    return 0
  fi

  log "starting tailscaled (userspace-networking)"
  mkdir -p "$(dirname "${TAILSCALE_SOCKET}")"
  mkdir -p "$(dirname "${TAILSCALE_LOG}")"

  nohup tailscaled \
    --state="${TAILSCALE_STATE}" \
    --socket="${TAILSCALE_SOCKET}" \
    --tun=userspace-networking \
    --socks5-server="${TAILSCALE_SOCKS}" \
    --outbound-http-proxy-listen="${TAILSCALE_HTTP}" \
    >>"${TAILSCALE_LOG}" 2>&1 &

  sleep 2
}

apply_tailscale_serve() {
  if ! command -v tailscale >/dev/null 2>&1; then
    log "tailscale CLI not found; skipping serve configuration"
    return 0
  fi

  ensure_tailscaled
  if tailscale serve --bg --yes "${GATEWAY_PORT}"; then
    log "tailscale serve configured for local port ${GATEWAY_PORT}"
  else
    log "WARNING: tailscale serve command failed"
  fi
}

ensure_adb() {
  if ! command -v adb >/dev/null 2>&1; then
    log "WARNING: adb not found"
    return 0
  fi

  adb start-server >/dev/null 2>&1 || true
  mapfile -t DEVICES < <(adb devices | awk 'NR>1 && $2=="device" {print $1}')

  if [ "${#DEVICES[@]}" -eq 0 ]; then
    log "WARNING: no adb device in 'device' state"
    adb devices || true
    return 0
  fi

  if [ -z "${DROIDRUN_SERIAL:-}" ]; then
    local pick=""
    for s in "${DEVICES[@]}"; do
      if [[ "${s}" == 127.0.0.1:5555 ]]; then
        pick="${s}"
        break
      fi
    done
    [ -n "${pick}" ] || pick="${DEVICES[0]}"
    export DROIDRUN_SERIAL="${pick}"
  fi

  log "adb selected serial: ${DROIDRUN_SERIAL}"
}

build_plugin() {
  if [ ! -d "${PLUGIN_DIR}" ]; then
    log "WARNING: plugin dir not found at ${PLUGIN_DIR}"
    return 0
  fi

  if [ ! -d "${PLUGIN_DIR}/dist" ] || [ ! -f "${PLUGIN_DIR}/dist/pyexec/android_exec.py" ]; then
    log "building plugin artifacts"
    (cd "${PLUGIN_DIR}" && npm install && npm run build)
  fi

  log "installing plugin via openclaw"
  openclaw plugins install "${PLUGIN_DIR}" || true
}

sync_workspace_seed() {
  append_block() {
    local target="$1"
    local block="$2"
    local marker="CLAWBOT_MOBILE_BEGIN"

    [ -f "$block" ] || return 0
    touch "$target"

    if ! grep -q "$marker" "$target"; then
      printf "\n\n" >>"$target"
      cat "$block" >>"$target"
      printf "\n" >>"$target"
      log "injected mobile block into $(basename "$target")"
    fi
  }

  append_block "${WORKSPACE}/AGENTS.md" "${SEED_DIR}/AGENTS.mobile.md"
  append_block "${WORKSPACE}/TOOLS.md" "${SEED_DIR}/TOOLS.mobile.md"
  append_block "${WORKSPACE}/CAPABILITIES.md" "${SEED_DIR}/CAPABILITIES.mobile.md"

  local rules_src="${SEED_DIR}/rules/clawbot-mobile"
  local rules_dst="${WORKSPACE}/rules/clawbot-mobile"
  if [ -d "${rules_src}" ]; then
    mkdir -p "${rules_dst}"
    rsync -a --delete "${rules_src}/" "${rules_dst}/"
    log "synced mobile rules"
  else
    log "WARNING: seed rules not found at ${rules_src}"
  fi
}

apply_telegram_cmd() {
  openclaw config set channels.telegram.customCommands '[{"command":"ime","description":"Restore the keyboard (IME)"}]' || true
}

prep_phone_stack() {
  source_env_patch
  activate_python
  import_droidrun_env
  ensure_adb
  build_plugin
  sync_workspace_seed
  apply_telegram_cmd
  apply_tailscale_serve
}

run_onboard() {
  source_env_patch
  activate_python
  log "launching openclaw onboard $*"
  openclaw onboard --skip-daemon "$@"
}

start_gateway() {
  prep_phone_stack
  log "starting openclaw gateway (bind=${GATEWAY_BIND} port=${GATEWAY_PORT})"
  exec openclaw gateway --bind "${GATEWAY_BIND}" --port "${GATEWAY_PORT}" --verbose
}

case "${COMMAND}" in
  start-gateway)
    start_gateway
    ;;
  prep-phone)
    prep_phone_stack
    ;;
  tailscale-ensure)
    ensure_tailscaled
    apply_tailscale_serve
    ;;
  adb-refresh)
    import_droidrun_env
    ensure_adb
    ;;
  restart-gateway)
    log "stopping existing openclaw gateway (if running)"
    pkill -f 'openclaw gateway' >/dev/null 2>&1 || true
    sleep 2
    start_gateway
    ;;
  onboard)
    run_onboard "$@"
    ;;
  *)
    echo "Usage: $0 {start-gateway|prep-phone|tailscale-ensure|adb-refresh|restart-gateway|onboard}" >&2
    exit 1
    ;;
esac
