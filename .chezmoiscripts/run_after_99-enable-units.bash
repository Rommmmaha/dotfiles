#!/usr/bin/env bash
echo -e "\n[#] enable-units.bash"
systemctl --user daemon-reload
systemctl --user reenable r_check-updates.timer quickshell.service hyprpolkitagent.service
if [ -f "$HOME/.config/systemd/user/pw-links.service" ]; then
  systemctl --user reenable pw-links.service
fi
