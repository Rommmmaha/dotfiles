local home = os.getenv("HOME")
local configPath = home .. "/.config/hypr"
-- =======================================================================================
-- Variables
-- =======================================================================================
hl.config({
  input = {
    kb_layout = "us, ua",
    kb_options = "grp:caps_toggle,fkeys:basic_13-24",
    numlock_by_default = true
  },
  general = {
    allow_tearing = true,
    gaps_in = 0,
    gaps_out = 0,
    border_size = 0,
    layout = "dwindle",
    resize_on_border = false,
    snap = {
      enabled = true,
      window_gap = 25,
      monitor_gap = 25
    }
  },
  decoration = {
    shadow = {
      sharp = true,
      range = 1,
      color = 0x33ffffff
    },
    blur = {
      size = 2,
      passes = 3,
      new_optimizations = true,
      noise = 0
    }
  },
  animations = {
    enabled = false
  },
  misc = {
    disable_hyprland_logo = true,
    disable_splash_rendering = true,
    background_color = 0x000000,
    render_unfocused_fps = 30
  },
  binds = {
    hide_special_on_workspace_change = true,
    scroll_event_delay = 0
  },
  group = {
    groupbar = {
      indicator_height = 0,
      text_color_inactive = 0x66ffffff,
      font_size = 10,
      gaps_in = 0,
      gaps_out = 0
    }
  },
  xwayland = {
    force_zero_scaling = true
  },
  ecosystem = {
    no_update_news = true,
    no_donation_nag = true
  },
  render = {
    cm_enabled = false
  }
})

-- Animations Configuration
hl.curve("fluent_decel", { type = "bezier", points = { { 0, 0.2 }, { 0.4, 1 } } })
hl.curve("easeOutExpo", { type = "bezier", points = { { 0.16, 1 }, { 0.3, 1 } } })

hl.animation({ leaf = "windows", enabled = true, speed = 3, bezier = "fluent_decel", style = "popin 80%" })
hl.animation({ leaf = "windowsIn", enabled = true, speed = 3, bezier = "easeOutExpo", style = "popin 60%" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 3, bezier = "fluent_decel", style = "popin 80%" })
hl.animation({ leaf = "border", enabled = true, speed = 10, bezier = "default" })
hl.animation({ leaf = "fade", enabled = true, speed = 3, bezier = "default" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 3.5, bezier = "easeOutExpo", style = "slide" })
hl.animation({ leaf = "specialWorkspace", enabled = true, speed = 3, bezier = "fluent_decel", style = "slidevert" })
-- =======================================================================================
-- Autostart
-- =======================================================================================
hl.on("hyprland.start", function()
  hl.exec_cmd("dbus-update-activation-environment --systemd --all")
  hl.exec_cmd("systemctl --user import-environment DISPLAY WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
  hl.exec_cmd("hyprpaper")
  hl.exec_cmd("systemctl --user start hyprpolkitagent")
  hl.exec_cmd("eww open main")
  hl.exec_cmd("kdeconnectd")
  hl.exec_cmd("wl-clip-persist --clipboard regular")
  hl.exec_cmd("wl-paste --watch clipvault store")
  hl.exec_cmd("kitty --single-instance --start-as=hidden")
end)
-- =======================================================================================
-- Keybinds
-- =======================================================================================
-- General
hl.bind("SUPER + Return", hl.dsp.exec_cmd("kitty --single-instance"))
hl.bind("SUPER + E", hl.dsp.exec_cmd("dolphin"))
hl.bind("SUPER + X", hl.dsp.exec_cmd("code -nq"))
hl.bind("SUPER + C", hl.dsp.exec_cmd("pwvucontrol"))

hl.bind("SHIFT + Escape", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })

hl.bind("SUPER + Backspace", function()
  local anims = hl.get_config("animations.enabled")
  hl.config({ animations = { enabled = not anims } })
end)

-- Screenshot
hl.bind("Print", hl.dsp.exec_cmd("flameshot gui"), { ignore_mods = true })
hl.bind("SUPER + SHIFT + S", hl.dsp.exec_cmd("flameshot gui"))
hl.bind("SUPER + P", function()
  local handle = io.popen('ls -t "' .. home .. '/Pictures/Screenshots/"* 2>/dev/null | head -n 1')
  if handle then
    local newest_file = handle:read("*l")
    handle:close()
    if newest_file and newest_file ~= "" then
      hl.dispatch(hl.dsp.exec_cmd("oculante \"" .. newest_file .. "\"", { float = true }))
    end
  end
end)

-- Rofi
hl.bind("SUPER + S", hl.dsp.exec_cmd("rofi -show drun -show-icons"))
hl.bind("SUPER + D", hl.dsp.exec_cmd("rofi -show window -show-icons"))
hl.bind("SUPER + Period", hl.dsp.exec_cmd("rofimoji"))
hl.bind("XF86Calculator", hl.dsp.exec_cmd("rofi -show calc -modi calc -no-show-match -no-sort"))
hl.bind("SUPER + V",
  hl.dsp.exec_cmd("rofi -modi clipboard:" .. configPath .. "/custom/r_clipvault.sh -show clipboard -show-icons")
)

-- Session
hl.bind("SUPER + Escape", hl.dsp.exit())
hl.bind("XF86PowerOff", hl.dsp.exit())
hl.bind("SUPER + L", hl.dsp.exec_cmd("hyprlock"))

-- Window management
hl.bind("SUPER + W", hl.dsp.window.close())
hl.bind("SUPER + F", hl.dsp.window.float({ action = "toggle" }))
hl.bind("SUPER + A", hl.dsp.window.fullscreen({ mode = "maximized" }))
hl.bind("SUPER + G", hl.dsp.group.toggle())

hl.bind("SUPER + Tab", function()
  hl.dispatch(hl.dsp.window.cycle_next())
  hl.dispatch(hl.dsp.window.alter_zorder({ mode = "top" }))
end)

-- Workspaces 1-9
hl.bind("SUPER + 0", hl.dsp.focus({ workspace = "10" }))
hl.bind("SUPER + SHIFT + 0", hl.dsp.window.move({ workspace = "10", follow = false }))
for i = 1, 9 do
  hl.bind("SUPER + " .. tostring(i), hl.dsp.focus({ workspace = tostring(i) }))
  hl.bind("SUPER + SHIFT + " .. tostring(i), hl.dsp.window.move({ workspace = tostring(i), follow = false }))
end

-- Custom workspaces (11-13)
local custom_ws = { ["Q"] = 11, ["Z"] = 12, ["GRAVE"] = 13 }
for key, ws_id in pairs(custom_ws) do
  -- Focus
  hl.bind("SUPER + " .. key, function()
    if hl.get_active_workspace().id == ws_id then
      hl.dispatch(hl.dsp.focus({ workspace = "previous" }))
    else
      hl.dispatch(hl.dsp.focus({ workspace = tostring(ws_id) }))
    end
  end)
  -- Move window to
  hl.bind("SUPER + SHIFT + " .. key, hl.dsp.window.move({ workspace = tostring(ws_id), follow = false }))
end

-- Move windows on layout
local directions = { LEFT = "l", RIGHT = "r", UP = "u", DOWN = "d" }
for key, dir in pairs(directions) do
  hl.bind("SUPER + CTRL + " .. key, hl.dsp.window.move({ direction = dir }))
end

-- Brightness keys
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl set 10%+"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl set 10%-"), { locked = true, repeating = true })

-- Mouse binds
hl.bind("SUPER + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind("SUPER + mouse:273", hl.dsp.window.resize(), { mouse = true })
-- =======================================================================================
-- Window Rules
-- =======================================================================================
hl.window_rule({ match = { float = false }, no_shadow = true })

hl.window_rule({ match = { class = "xdg-desktop-portal-gtk" }, float = true })
hl.window_rule({ match = { class = [[org\.freedesktop\.impl\.portal\.desktop\.kde]] }, float = true })

hl.window_rule({
  name = "volume-menu",
  match = { class = [[pipemixer|com\.saivert\.pwvucontrol]] },
  float = true,
  size = "{860, 540}",
  center = true
})

hl.window_rule({
  name = "flameshot",
  match = { title = "flameshot" },
  float = true,
  size = "{1920, 1080}",
  move = "{0, 0}",
  pin = true,
  stay_focused = true
})

hl.window_rule({ match = { class = "steam" }, suppress_event = "maximize fullscreen" })

hl.window_rule({
  name = "game",
  match = { class = "gamescope|mcpelauncher-client|steam_app_.*|Minecraft.*" },
  tile = true,
  opaque = true,
  force_rgbx = true,
  render_unfocused = true,
  immediate = true
})
-- =======================================================================================
-- Layer Rules
-- =======================================================================================
hl.layer_rule({
  match = { namespace = "swaync-(notification-window|control-center)|rofi|gtk-layer-shell" },
  blur = true,
  ignore_alpha = 0
})
-- =======================================================================================
-- Device Specific Rules
-- =======================================================================================
local handle = io.popen("ls \"" .. configPath .. "/custom/hyprland-\"*.lua 2>/dev/null")
if handle then
  for file in handle:lines() do
    dofile(file)
  end
  handle:close()
end
