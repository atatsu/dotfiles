local awful = require("awful")
local wibox = require("wibox")
local vicious = require("vicious")
local beautiful = require("beautiful")
local giblets = require("giblets")

-- function aliases
local pread = awful.util.pread
local sexec = awful.util.spawn_with_shell
local exec = awful.util.spawn

local cache = {}

-- initialized after module loaded
local spacer_text

local M = {}

-- {{{ Spacer widget
local create_spacer = function()
  local spacer = wibox.widget.textbox()
  spacer:set_text(spacer_text)
  M.spacer = spacer
end
-- }}}

-- {{{ Pacman updates
function M.add_pacman(layout)
  if not cache.pacman then
    -- icon
    local pacicon = wibox.widget.imagebox()
    pacicon:set_image(beautiful.widget_pacman)
    -- widget
    local pacwidget = wibox.widget.textbox()
    local pacupdate = function()
      return pread("pacman -Qu | wc -l")
    end
    pacwidget:set_text(pacupdate())
    -- buttons
    -- left-click, xmessage popup with packages to update
    local pacbuttons = awful.button(
      {}, 
      1, 
      function() sexec("pacman -Qu | xmessage -file - -nearmouse") end
    )
    -- now bind the buttons to the icon and widget
    pacicon:buttons(pacbuttons)
    pacwidget:buttons(pacbuttons)
    -- timer to update the widget text periodically
    local pactimer = timer({timeout = 3637})
    pactimer:connect_signal(
      "timeout",
      function() pacwidget:set_text(pacupdate()) end
    )
    pactimer:start()

    cache.pacman = {pacicon, pacwidget, M.spacer}
  end

  for _, v in ipairs(cache.pacman) do
    layout:add(v)
  end
end
-- }}}

-- {{{ Volume widget
function M.add_volume(layout)
  if not cache.volume then
    -- set icon
    local volicon = wibox.widget.imagebox()
    volicon:set_image(beautiful.widget_volume)
    -- create and register widget
    local volwidget = wibox.widget.textbox()
    vicious.register(volwidget, vicious.widgets.volume, "$1", 13, "Master")

    cache.volume = {volicon, volwidget, M.spacer}
  end

  for _, v in ipairs(cache.volume) do
    layout:add(v)
  end
end
-- }}}

-- {{{ MPD widget
function M.add_mpd(layout)
  if not cache.mpd then
    -- set icon
    local mpdicon = wibox.widget.imagebox()
    mpdicon:set_image(beautiful.widget_mpd)
    -- create and register widget
    local mpdwidget = wibox.widget.textbox()
    vicious.register(mpdwidget, vicious.widgets.mpd, function(mpdwidget, args)
      if args["{state}"] == "Stop" then
        return " - "
      else
        return args["{Artist}"] .. ' - ' .. args["{Title}"]
      end
    end, 11)

    cache.mpd = {mpdicon, mpdwidget, M.spacer}
  end

  for _, v in ipairs(cache.mpd) do
    layout:add(v)
  end
end
-- }}}

-- {{{ CPU widget
function M.add_cpu(layout)
  if not cache.cpu then
    -- set icon
    local cpuicon = wibox.widget.imagebox()
    cpuicon:set_image(beautiful.widget_cpu)
    -- create and register widget
    local cpuwidget = awful.widget.graph()
    cpuwidget:set_width(40)
    cpuwidget:set_background_color(beautiful.bg_normal)
    cpuwidget:set_color({
      type = "linear",
      from = {0, 0},
      to = {10, 0},
      stops = {
        {0, "#ff5656",},
        {0.5, "#88a175"},
        {1, "#aecf96"},
      },
    })
    vicious.register(cpuwidget, vicious.widgets.cpu, "$1")

    cache.cpu = {cpuicon, cpuwidget, M.spacer}
  end

  for _, v in ipairs(cache.cpu) do
    layout:add(v)
  end
end
-- }}}

-- {{{ Memory widget
function M.add_mem(layout)
  if not cache.mem then
    -- set icon
    local memicon = wibox.widget.imagebox()
    memicon:set_image(beautiful.widget_mem)
    -- create and register widget
    local memwidget = wibox.widget.textbox()
    vicious.register(memwidget, vicious.widgets.mem, "$1% ($2MB/$3MB)", 13)

    cache.mem = {memicon, memwidget, M.spacer}
  end

  for _, v in ipairs(cache.mem) do
    layout:add(v)
  end
end
-- }}}

-- {{{ Clock/date widget
function M.add_clock(layout)
  if not cache.clock then
    -- set icon
    local clockicon = wibox.widget.imagebox()
    clockicon:set_image(beautiful.widget_clock)
    -- create widget
    local clockwidget = awful.widget.textclock()

    cache.clock = {clockicon, clockwidget, M.spacer}
  end

  for _, v in ipairs(cache.clock) do
    layout:add(v)
  end
end
-- }}}

-- {{{ Disk usage widget
function M.add_diskusage(layout)
  if not cache.diskusage then
    local diskusage = giblets.gizmos.diskusage(
      beautiful.widget_disk,
      {
        {mount = "/home", label = "home"},
        {mount = "/games", label = "games"},
        {mount = "/videos", label = "vids"},
        {mount = "/home/atatsu/dev", label = "dev"},
        {mount = "/copy", label = "copy"},
        {mount = "/var", label = "var"},
      },
      {
        width = 306,
        height = 180,
        --border_width = 1,
        --border_color = "#ffffff",
      }
    )
    diskusage:tune_progressbars(function(progressbar)
      progressbar:set_ticks_size({width = 8, height = 6})
    end)

    cache.diskusage = {diskusage, M.spacer}
  end

  for _, v in ipairs(cache.diskusage) do
    layout:add(v)
  end
end
-- }}}

function M.init(_spacer_text)
  spacer_text = _spacer_text or " "

  create_spacer()
end

return M
