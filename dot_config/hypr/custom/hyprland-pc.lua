-- =======================================================================================
-- Device & Display
-- =======================================================================================
hl.monitor({
  output = "DP-1",
  mode = "1920x1080@144",
  position = "0x0",
  bitdepth = 8,
  scale = 1,
  vrr = 1
})
hl.config({
  input = {
    sensitivity = -0.5
  },
  misc = {
    vrr = 1
  }
})
-- =======================================================================================
-- Autostart
-- =======================================================================================
hl.on("hyprland.start", function()
  hl.dispatch(hl.dsp.focus({ workspace = "2" }))
  hl.exec_cmd("rm -rf " .. os.getenv("HOME") .. "/.config/obs-studio/.sentinel")
  hl.exec_cmd("Telegram", { workspace = "1 silent" })
  hl.exec_cmd("discord", { workspace = "1 silent" })
  hl.exec_cmd("zen-browser", { workspace = "3 silent" })
  hl.exec_cmd("steam -silent")
  hl.exec_cmd("r_record clip")
  hl.exec_cmd("r_sndcpy")
  hl.exec_cmd("r_overlay --udp 7435")
end)
hl.window_rule({ match = { class = "discord|vesktop|equibop" }, workspace = "1 silent" })
hl.window_rule({ match = { initial_title = "Discord" }, workspace = "1 silent" })
-- =======================================================================================
-- Keybinds
-- =======================================================================================
hl.bind("SUPER + F1", hl.dsp.exec_cmd("r_record toggle-mode"))
hl.bind("SUPER + F2", hl.dsp.exec_cmd("r_record clip"))
hl.bind("mouse:276", hl.dsp.exec_cmd("r_multitool cycle"), { ignore_mods = true })
hl.bind("mouse:275", hl.dsp.exec_cmd("r_multitool ptt 1"), { ignore_mods = true })
hl.bind("mouse:275", hl.dsp.exec_cmd("r_multitool ptt 0"), { ignore_mods = true, release = true })
hl.bind("SUPER + mouse_down", hl.dsp.exec_cmd("r_multitool vol 2%-"), { bypass = true, locked = true })
hl.bind("SUPER + mouse_up", hl.dsp.exec_cmd("r_multitool vol 2%+"), { bypass = true, locked = true })
hl.bind("XF86Mail", hl.dsp.exec_cmd([[r_multitool ptt 1 --color 00AAFF && r_env GROQ_API_KEY -- r_stt | wtype -d 10 -]]))
hl.bind("XF86Mail", hl.dsp.exec_cmd("r_multitool ptt 0 && killall -USR1 r_stt"), { release = true })
