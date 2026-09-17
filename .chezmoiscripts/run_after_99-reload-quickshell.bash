#!/usr/bin/env bash
echo -e "\n[#] reload-quickshell.bash"
if killall -w qs 2>/dev/null; then
  qs </dev/null >/dev/null 2>&1 &
  disown
  echo "[+] quickshell reloaded successfully."
else
  echo "[!] quickshell was not running."
fi
