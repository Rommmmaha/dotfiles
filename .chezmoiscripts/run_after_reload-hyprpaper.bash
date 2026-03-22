#!/usr/bin/env bash

if killall -w hyprpaper 2>/dev/null; then
  hyprpaper < /dev/null > /dev/null 2>&1 & disown
  echo "[+] hyprpaper reloaded successfully."
else
  echo "[!] hyprpaper was not running."
fi