#!/usr/bin/env sh
command -v yay >/dev/null 2>&1 && exit 0

sudo pacman -S --needed --noconfirm base-devel git
git clone --depth=1 https://aur.archlinux.org/yay-bin.git /tmp/yay-bin
(cd /tmp/yay-bin && makepkg -si --noconfirm)
rm -rf /tmp/yay-bin
