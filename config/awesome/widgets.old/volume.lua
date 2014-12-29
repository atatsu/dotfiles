local awful = require("awful")
local wibox = require("wibox")
local pread = awful.util.pread
local exec = awful.util.spawn
local beautiful = require("beautiful")
beautiful.init(awful.util.getdir("config") .. "/oblivion.lua")

local scripts = awful.util.getdir("config") .. "/scripts/"

local volicon = wibox.widget.imagebox()
volicon:set_image(beautiful.widget_volume)
local volwidget = wibox.widget.textbox()
volwidget:set_text(pread(scripts .. "volume Master"))

local volume_buttons = awful.util.table.join(
    awful.button({ }, 1, function () exec("pavucontrol") end), -- Left click
    awful.button({ }, 4, function () -- Scroll up
        exec("amixer set Master 1%+ >/dev/null") 
        volwidget:set_text(pread(scripts .. "volume Master"))
    end), 
    awful.button({ "Control" }, 4, function () -- Scroll up + Control
        exec("amixer set Master 5%+ >/dev/null") 
        volwidget:set_text(pread(scripts .. "volume Master"))
    end), 
    awful.button({ }, 5, function () -- Scroll down
        exec("amixer set Master 1%- >/dev/null") 
        volwidget:set_text(pread(scripts .. "volume Master"))
    end), 
    awful.button({ "Control" }, 5, function () -- Scroll down + Control
        exec("amixer set Master 5%- >/dev/null") 
        volwidget:set_text(pread(scripts .. "volume Master"))
    end)  
)

volwidget:buttons(volume_buttons)
volicon:buttons(volume_buttons)

local voltimer = timer({ timeout = 3 })
voltimer:connect_signal("timeout", function () volwidget:set_text(pread(scripts .. "volume Master")) end)
voltimer:start()

local volume = {
    icon = volicon, 
    widget = volwidget, 
    timer = voltimer
}

return volume
