-- =======================================================================================
-- Device & Display
-- =======================================================================================
hl.monitor({
  output = "eDP-1",
  mode = "1920x1080@60",
  position = "0x0",
  bitdepth = 8,
  scale = 1
})
-- =======================================================================================
-- Self-locking mechanism
-- =======================================================================================
local lid_closed_time = nil
hl.bind("switch:on:Lid Switch", function()
  lid_closed_time = os.time()
  hl.dispatch(hl.dsp.exec_cmd("pidof hyprlock || hyprlock"))
end)
hl.bind("switch:off:Lid Switch", function()
  if lid_closed_time and (os.time() - lid_closed_time <= 5) then
    hl.dispatch(hl.dsp.exec_cmd("pkill -USR1 hyprlock"))
  end
  lid_closed_time = nil
end, { locked = true })
