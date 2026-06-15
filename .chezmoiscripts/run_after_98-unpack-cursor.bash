#!/usr/bin/env bash
if [ ! -d "$HOME/.icons/GoogleDot-Black" ]; then
    mkdir -p "$HOME/.icons"
    tar -xzf "$HOME/.local/share/chezmoi/.archives/GoogleDot-Black.tar.gz" -C "$HOME/.icons"
fi