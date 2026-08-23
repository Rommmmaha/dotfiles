#!/usr/bin/env sh
command -v python3 >/dev/null 2>&1 && exit 0
echo -e "\n[#] install-python.sh"
sudo pacman -S --needed --noconfirm python3
