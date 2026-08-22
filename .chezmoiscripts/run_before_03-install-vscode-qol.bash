#!/usr/bin/env bash
command -v code >/dev/null 2>&1 || exit 0
echo -e "\n[#] install-vscode-qol.bash"
URL="https://github.com/Rommmmaha/vscode/releases/download/nightly/qol.vsix"
INSTALL_DIR="$HOME/.cache/r/updater/vscode-qol"
ETAG_FILE="$INSTALL_DIR/latest.etag"
VSIX_FILE="$INSTALL_DIR/qol.vsix"
mkdir -p "$INSTALL_DIR"
echo "[+] Checking for VSCode extension updates..."
HTTP_CODE=$(curl -sL --fail --progress-bar \
  --etag-compare "$ETAG_FILE" \
  --etag-save "$ETAG_FILE" \
  -o "$VSIX_FILE" \
  -w "%{http_code}" \
  "$URL")
if [ "$HTTP_CODE" -eq 304 ]; then
  echo "[+] Already up-to-date. Skipping."
  exit 0
fi
echo "[+] New version downloaded! Installing..."
code --install-extension "$VSIX_FILE" --force
rm -f "$VSIX_FILE"
echo "[!] Done."
