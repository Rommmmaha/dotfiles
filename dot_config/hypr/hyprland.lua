local home = os.getenv("HOME")
local configPath = home .. "/.config/hypr"
local RUN = "systemd-run --user --scope --slice=app.slice -- "
-- =======================================================================================
-- Variables
-- =======================================================================================
hl.config({
  animations = {
    enabled = true
  },
  binds = {
    hide_special_on_workspace_change = true,
    scroll_event_delay = 0
  },
  decoration = {
    blur = {
      passes = 3,
      size = 2
    },
    shadow = {
      color = "#ffffff33",
      range = 3
    }
  },
  ecosystem = {
    no_donation_nag = true,
    no_update_news = true
  },
  general = {
    allow_tearing = true,
    border_size = 0,
    gaps_in = 0,
    gaps_out = 0,
    layout = "dwindle",
    resize_on_border = false,
    snap = {
      enabled = true,
      monitor_gap = 25,
      window_gap = 25
    }
  },
  group = {
    groupbar = {
      font_size = 12,
      gaps_in = 0,
      gaps_out = 0,
      gradient_rounding = 0,
      gradients = true,
      height = 16,
      indicator_height = 0,
      rounding = 0,
      text_color_inactive = "#ffffff88",
      col = {
        active = "#000000ff",
        inactive = "#000000ff",
        locked_active = "#000000ff",
        locked_inactive = "#000000ff"
      }
    }
  },
  input = {
    kb_layout = "us, ua",
    kb_options = "grp:caps_toggle,fkeys:basic_13-24",
    numlock_by_default = true
  },
  misc = {
    background_color = "#000000",
    disable_hyprland_logo = true,
    disable_splash_rendering = true,
    initial_workspace_tracking = 0,
    render_unfocused_fps = 30
  },
  render = {
    cm_enabled = false
  },
  xwayland = {
    force_zero_scaling = true
  }
})
-- =======================================================================================
-- ANIMATION CURVES
-- =======================================================================================
hl.curve("fade", { type = "bezier", points = { { 0.0, 0.0 }, { 1.0, 1.0 } } })
hl.curve("ultra_snappy", { type = "bezier", points = { { 0.1, 0.9 }, { 0.1, 1.0 } } })
hl.curve("fast_spring", { type = "spring", mass = 1, stiffness = 500, dampening = 45 })
-- =======================================================================================
-- ANIMATIONS
-- =======================================================================================
hl.animation({ leaf = "global", enabled = true, speed = 1.4, bezier = "ultra_snappy" })
-- Window animations
hl.animation({ leaf = "windowsIn", enabled = true, speed = 3.0, bezier = "ultra_snappy", style = "popin 0%" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 3.0, bezier = "default", style = "popin 100%" })
hl.animation({ leaf = "windowsMove", enabled = true, speed = 1.4, spring = "fast_spring" })
-- Fade animations
hl.animation({ leaf = "fade", enabled = true, speed = 1.0, bezier = "fade" })
hl.animation({ leaf = "fadeOut", enabled = true, speed = 3.0, bezier = "fade" })
hl.animation({ leaf = "fadeLayersOut", enabled = true, speed = 3.0, bezier = "fade" })
hl.animation({ leaf = "fadePopupsOut", enabled = true, speed = 3.0, bezier = "fade" })
hl.animation({ leaf = "fadeSwitch", enabled = true, speed = 1.0, bezier = "ultra_snappy" })
-- Layer & Workspace animations
hl.animation({ leaf = "layers", enabled = true, speed = 1.0, bezier = "ultra_snappy", style = "popin 90%" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 1.5, bezier = "ultra_snappy", style = "slidefade 10%" })
hl.animation({ leaf = "specialWorkspace", enabled = true, speed = 1.4, bezier = "ultra_snappy", style = "slidefade 10%" })
-- =======================================================================================
-- Autostart
-- =======================================================================================
hl.on("hyprland.start", function()
  hl.exec_cmd("systemctl --user restart hyprland-session.target")
  hl.exec_cmd("systemctl --user restart hyprpolkitagent")
  hl.exec_cmd("hyprpm reload")
  hl.exec_cmd(RUN .. "hyprpaper")
  hl.exec_cmd(RUN .. "qs")
  hl.exec_cmd(RUN .. "kdeconnectd")
  hl.exec_cmd(RUN .. "wl-clip-persist --clipboard regular")
  hl.exec_cmd(RUN .. "wl-paste --type text --watch cliphist store")
  hl.exec_cmd(RUN .. "wl-paste --type image --watch cliphist store")
  hl.exec_cmd(RUN .. "kitty --single-instance --start-as=hidden")
  hl.exec_cmd(RUN .. "r_check-updates --loop")
  hl.exec_cmd(RUN .. "autostart")
end)
hl.on("hyprland.shutdown", function()
  os.execute("systemctl --user stop hyprland-session.target && sleep 1")
end)
-- =======================================================================================
-- Keybinds
-- =======================================================================================
-- General
hl.bind("SUPER + Return", hl.dsp.exec_cmd("kitty --single-instance"))
hl.bind("SUPER + E", hl.dsp.exec_cmd(RUN .. "dolphin"))
hl.bind("SUPER + X", hl.dsp.exec_cmd(RUN .. "code -nq"))
hl.bind("SUPER + C", hl.dsp.exec_cmd(RUN .. "flatpak run com.saivert.pwvucontrol"))

hl.bind("SHIFT + Escape", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })

hl.bind("SUPER + Backspace", function()
  hl.config({ animations = { enabled = not hl.get_config("animations.enabled") } })
end)

-- Screenshot
SCREENSHOT =
[[flameshot gui && wl-copy < "$(ls -td ~/Pictures/Screenshots/*.png | head -n 1)"]]
hl.bind("Print", hl.dsp.exec_cmd(SCREENSHOT), { ignore_mods = true })
hl.bind("SUPER + SHIFT + S", hl.dsp.exec_cmd(SCREENSHOT))
hl.bind("SUPER + P", hl.dsp.exec_cmd("xdg-open \"$(ls -td ~/Pictures/Screenshots/* | head -n 1)\"", { float = true }))

-- Rofi
hl.bind("SUPER + S", hl.dsp.exec_cmd("rofi -show drun -show-icons"))
hl.bind("SUPER + D", hl.dsp.exec_cmd("rofi -show window -show-icons"))
hl.bind("SUPER + Period", hl.dsp.exec_cmd("rofimoji"))
hl.bind("XF86Calculator", hl.dsp.exec_cmd("rofi -show calc -modi calc -no-show-match -no-sort"))
hl.bind("SUPER + V", hl.dsp.exec_cmd("rofi -modi clipboard:r_cliphist-rofi -show clipboard -show-icons"))

-- Session
hl.bind("SUPER + Escape", hl.dsp.exec_cmd("hyprshutdown"))
hl.bind("XF86PowerOff", hl.dsp.exec_cmd("hyprshutdown"))
hl.bind("SUPER + L", hl.dsp.exec_cmd(RUN .. "hyprlock"))

-- Window management
hl.bind("SUPER + W", function()
  local w = hl.get_active_window()
  if not w or w.class == "gamescope" then return end
  hl.dispatch(hl.dsp.window.close({ window = w }))
end)
hl.bind("SUPER + F4", hl.dsp.window.kill())
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
  match = { namespace = "rofi|r-(clock|notifications)" },
  blur = true,
  ignore_alpha = 0
})
-- =======================================================================================
-- Device Specific Rules
-- =======================================================================================
for f in io.popen('ls "' .. configPath .. '/custom/hyprland-"*.lua 2>/dev/null'):lines()
do
  require("custom." .. f:match("hyprland%-[^%.]+"))
end
-- =======================================================================================
-- Plugins
-- =======================================================================================
if hl.plugin then
  if hl.plugin.hyprstretch then
    hl.plugin.hyprstretch.app({ class = "cs2" })
    hl.plugin.hyprstretch.app({ class = "dota2" })
    hl.plugin.hyprstretch.app({ class = ".*\\.exe" })
  end
  hl.bind("SUPER + R", function() hl.plugin.hyprstretch.toggle() end)
end
