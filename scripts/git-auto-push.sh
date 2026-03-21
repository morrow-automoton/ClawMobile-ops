#!/bin/bash
set -euo pipefail

REPO_DIR="/root/.openclaw/workspace"
LOG_FILE="$REPO_DIR/scripts/git-auto-push.log"

cd "$REPO_DIR"

# Exit early if nothing changed
if git status --porcelain | grep -q "."; then
  git add -A
  COMMIT_MSG="Auto backup: $(date -u '+%Y-%m-%d %H:%M:%S UTC')"
  if git commit -m "$COMMIT_MSG" >/dev/null 2>&1; then
    if git push origin main >/dev/null 2>&1; then
      printf "%s | Pushed backup\n" "$(date -u '+%Y-%m-%dT%H:%M:%SZ')" >> "$LOG_FILE"
    else
      printf "%s | Push failed\n" "$(date -u '+%Y-%m-%dT%H:%M:%SZ')" >> "$LOG_FILE"
    fi
  else
    printf "%s | Commit failed\n" "$(date -u '+%Y-%m-%dT%H:%M:%SZ')" >> "$LOG_FILE"
  fi
else
  printf "%s | No changes\n" "$(date -u '+%Y-%m-%dT%H:%M:%SZ')" >> "$LOG_FILE"
fi
