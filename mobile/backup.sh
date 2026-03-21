#!/usr/bin/env bash
set -euo pipefail

ADB_BIN="${ADB_BIN:-adb}"
DEST_BASE="${DEST_BASE:-/sdcard/ClawMobileBackup}"
TIMESTAMP="$(date -u +%Y-%m-%d_%H-%M-%SUTC)"

FILES=(
  "/root/.openclaw/openclaw.json|openclaw/openclaw.json"
  "/root/.openclaw/workspace/AGENTS.md|workspace/AGENTS.md"
  "/root/.openclaw/workspace/USER.md|workspace/USER.md"
  "/root/.openclaw/workspace/TOOLS.md|workspace/TOOLS.md"
  "/root/.openclaw/workspace/mobile/README.md|workspace/mobile/README.md"
  "/data/data/com.termux/files/home/ClawMobile/installer/termux/run.sh|ClawMobile/installer/termux/run.sh"
  "/data/data/com.termux/files/home/ClawMobile/installer/termux/run.sh_reference|ClawMobile/installer/termux/run.sh_reference"
  "/data/data/com.termux/files/home/ClawMobile/installer/termux/onboard.sh|ClawMobile/installer/termux/onboard.sh"
  "/data/data/com.termux/files/home/ClawMobile/installer/ubuntu/mobile-runner.sh|ClawMobile/installer/ubuntu/mobile-runner.sh"
  "/root/.openclaw/workspace/mobile/backup.sh|workspace/mobile/backup.sh"
)

DIRS=(
  "/root/.openclaw/workspace/memory|workspace/memory"
  "/root/.openclaw/workspace/custom|workspace/custom"
)

log() { echo "[backup][$TIMESTAMP] $*"; }

list_backups() {
  "$ADB_BIN" shell "ls -1 ${DEST_BASE}" 2>/dev/null | tr -d '\r' | sed -n 's/^\([0-9].*\)$/\1/p' || true
}

backup_epoch_from_name() {
  local name="$1"
  python - <<'PY' "$name" || echo 0
import sys, datetime
name = sys.argv[1].rstrip('/')
if not name:
    print(0)
    raise SystemExit
if name.endswith('UTC'):
    name = name[:-3]
try:
    dt = datetime.datetime.strptime(name, "%Y-%m-%d_%H-%M-%S")
except ValueError:
    print(0)
else:
    print(int(dt.replace(tzinfo=datetime.timezone.utc).timestamp()))
PY
}

latest_backup() {
  local latest=""
  mapfile -t existing < <(list_backups | sort)
  if [ "${#existing[@]}" -gt 0 ]; then
    latest="${existing[-1]}"
  fi
  echo "$latest"
}

file_epoch() {
  local path="$1"
  [ -e "$path" ] || { echo 0; return; }
  stat -c %Y "$path" 2>/dev/null || echo 0
}

dir_epoch() {
  local dir="$1"
  [ -d "$dir" ] || { echo 0; return; }
  local latest=0
  while IFS= read -r f; do
    local ts
    ts=$(stat -c %Y "$f" 2>/dev/null || echo 0)
    if [ "$ts" -gt "$latest" ]; then
      latest="$ts"
    fi
  done < <(find "$dir" -type f 2>/dev/null)
  if [ "$latest" -eq 0 ]; then
    latest=$(stat -c %Y "$dir" 2>/dev/null || echo 0)
  fi
  echo "$latest"
}

prune_old_backups() {
  mapfile -t existing < <(list_backups | sort)
  local keep=${1:-1}
  local count=${#existing[@]}
  if [ "$count" -le "$keep" ]; then
    return
  fi
  local to_delete=$((count-keep))
  for ((i=0; i<to_delete; i++)); do
    local name="${existing[$i]}"
    if [ -n "$name" ]; then
      log "Deleting old backup $name"
      "$ADB_BIN" shell "rm -rf '${DEST_BASE}/${name}'" >/dev/null 2>&1 || true
    fi
  done
}

LATEST_NAME=$(latest_backup)
LATEST_EPOCH=0
if [ -n "$LATEST_NAME" ]; then
  LATEST_EPOCH=$(backup_epoch_from_name "$LATEST_NAME")
fi

SOURCE_EPOCH=0
for entry in "${FILES[@]}"; do
  IFS='|' read -r src _ <<<"$entry"
  ts=$(file_epoch "$src")
  if [ "$ts" -gt "$SOURCE_EPOCH" ]; then
    SOURCE_EPOCH="$ts"
  fi
  unset IFS
done
for entry in "${DIRS[@]}"; do
  IFS='|' read -r src _ <<<"$entry"
  ts=$(dir_epoch "$src")
  if [ "$ts" -gt "$SOURCE_EPOCH" ]; then
    SOURCE_EPOCH="$ts"
  fi
  unset IFS
done

if [ -n "$LATEST_NAME" ] && [ "$SOURCE_EPOCH" -le "$LATEST_EPOCH" ]; then
  log "No changes detected since last backup ($LATEST_NAME); skipping."
  exit 0
fi

BACKUP_ROOT="${DEST_BASE}/${TIMESTAMP}"
log "Creating backup at $BACKUP_ROOT"
"$ADB_BIN" shell "mkdir -p '$BACKUP_ROOT'" >/dev/null

copy_file() {
  local src="$1"
  local rel="$2"
  local dest="$BACKUP_ROOT/$rel"
  local dest_dir
  dest_dir="$(dirname "$dest")"
  "$ADB_BIN" shell "mkdir -p '$dest_dir'" >/dev/null
  log "Pushing $src -> $dest"
  "$ADB_BIN" push "$src" "$dest" >/dev/null
}

copy_dir() {
  local src="$1"
  local rel="$2"
  local dest="$BACKUP_ROOT/$rel"
  "$ADB_BIN" shell "mkdir -p '$dest'" >/dev/null
  log "Pushing directory $src -> $dest/"
  "$ADB_BIN" push -a "$src" "$dest" >/dev/null
}

for entry in "${FILES[@]}"; do
  IFS='|' read -r src rel <<<"$entry"
  if [ -f "$src" ]; then
    copy_file "$src" "$rel"
  else
    log "WARNING: missing file $src"
  fi
  unset IFS
done

for entry in "${DIRS[@]}"; do
  IFS='|' read -r src rel <<<"$entry"
  if [ -d "$src" ]; then
    copy_dir "$src" "$rel"
  else
    log "WARNING: missing directory $src"
  fi
  unset IFS
done

log "Backup complete: $BACKUP_ROOT"
prune_old_backups 1
