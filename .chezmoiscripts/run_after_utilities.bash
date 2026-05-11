#!/usr/bin/env bash
echo -e "\n[#] run_after_utilities.bash"
URL="https://github.com/Rommmmaha/r-utils/releases/download/nightly/linux.tar.gz"
INSTALL_DIR="$HOME/.local/bin"
CACHE_DIR="$HOME/.cache/r-utils-updater"
ETAG_FILE="$CACHE_DIR/latest.etag"
ARCHIVE_FILE="$CACHE_DIR/linux.tar.gz"
mkdir -p "$INSTALL_DIR" "$CACHE_DIR"
echo "[+] Checking for r-utils updates..."
HTTP_CODE=$(curl -sL --fail --progress-bar \
  --etag-compare "$ETAG_FILE" \
  --etag-save "$ETAG_FILE" \
  -o "$ARCHIVE_FILE" \
  -w "%{http_code}" \
  "$URL")
if [ "$HTTP_CODE" -eq 304 ]; then
  echo "[+] Already up-to-date. Skipping."
  exit 0
fi
echo "[+] New version downloaded! Extracting..."
tar -xzf "$ARCHIVE_FILE" -C "$INSTALL_DIR"
echo "[!] Done."