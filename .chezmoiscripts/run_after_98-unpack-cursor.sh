#!/usr/bin/env sh
echo -e "\n[#] unpack-cursor.sh"
mkdir -p "$HOME/.local/share/icons"
tar -xzf "$HOME/.local/share/chezmoi/.archives/GoogleDot-Black.tar.gz" -C "$HOME/.local/share/icons"
