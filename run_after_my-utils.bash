#!/usr/bin/env bash

# ================= CONFIGURATION =================
GITHUB_USER="Rommmmaha"
REPO_NAME="my-utils"
BINARY_ARCHIVE_NAME="linux-tools.tar.gz"
INSTALL_DIR="$HOME/.local/bin"
VERSION_FILE="$INSTALL_DIR/.my_tools_last_id"
# =================================================

set -e
if ! curl -s --head --max-time 2 https://api.github.com > /dev/null; then
    echo "Offline: Skipping update check."
    exit 0
fi
API_URL="https://api.github.com/repos/$GITHUB_USER/$REPO_NAME/releases?per_page=1"
RELEASE_JSON=$(curl -s "$API_URL")
if [[ $(echo "$RELEASE_JSON" | jq 'type == "array"' 2>/dev/null) != "true" ]]; then
    exit 0
fi
if [[ $(echo "$RELEASE_JSON" | jq 'length') -eq 0 ]]; then
    exit 0
fi
REMOTE_ID=$(echo "$RELEASE_JSON" | jq -r '.[0].id')
TAG_NAME=$(echo "$RELEASE_JSON" | jq -r '.[0].tag_name')
DOWNLOAD_URL=$(echo "$RELEASE_JSON" | jq -r ".[0].assets[] | select(.name==\"$BINARY_ARCHIVE_NAME\") | .browser_download_url")
if [ -z "$DOWNLOAD_URL" ] || [ "$DOWNLOAD_URL" == "null" ]; then
    exit 0
fi
LOCAL_ID=""
[ -f "$VERSION_FILE" ] && LOCAL_ID=$(cat "$VERSION_FILE")
if [ "$REMOTE_ID" == "$LOCAL_ID" ]; then
    exit 0
fi
echo "Updating $REPO_NAME to $TAG_NAME..."
TMP_DIR=$(mktemp -d)
curl -L -o "$TMP_DIR/tools.tar.gz" "$DOWNLOAD_URL" --progress-bar
mkdir -p "$INSTALL_DIR"
tar -xzf "$TMP_DIR/tools.tar.gz" -C "$INSTALL_DIR"
echo "$REMOTE_ID" > "$VERSION_FILE"
rm -rf "$TMP_DIR"
echo "Done."