#!/usr/bin/env bash
set -euo pipefail
command -v yay >/dev/null 2>&1 && exit 0
echo -e "\n[#] install-yay.sh"
sudo pacman -S --needed --noconfirm base-devel git
TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT
git clone --depth=1 https://aur.archlinux.org/yay-bin.git "$TMPDIR"
(cd "$TMPDIR" && makepkg -si --noconfirm)
