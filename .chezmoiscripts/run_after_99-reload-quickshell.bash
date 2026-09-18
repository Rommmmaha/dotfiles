#!/usr/bin/env bash
echo -e "\n[#] reload-quickshell.bash"
systemctl --user daemon-reload
killall -w quickshell 2>/dev/null
systemctl --user restart quickshell.service
if systemctl --user is-active -q quickshell.service; then
  echo "[+] quickshell reloaded successfully."
else
  echo "[!] quickshell failed to start."
fi
