#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail
LABEL="${1:-screen}"
WORKSPACE="/root/.openclaw/workspace"
RAW_DIR="/data/data/com.termux/files/home"
RAW_FILE="${RAW_DIR}/.tmp_screencap.png"
TIMESTAMP="$(date -u +%Y%m%d-%H%M%S)"
DEST_DIR="${WORKSPACE}/farcaster/screens"
RAW_DEST="${DEST_DIR}/${TIMESTAMP}-${LABEL}.png"
SMALL_DEST="${DEST_DIR}/${TIMESTAMP}-${LABEL}-small.jpg"

mkdir -p "${DEST_DIR}"

screencap -p "${RAW_FILE}"
cp "${RAW_FILE}" "${RAW_DEST}"
rm -f "${RAW_FILE}"

"${WORKSPACE}/scripts/resize_image.py" "${RAW_DEST}" "${SMALL_DEST}" 1080

echo "Saved ${RAW_DEST}" && echo "Saved ${SMALL_DEST}"
