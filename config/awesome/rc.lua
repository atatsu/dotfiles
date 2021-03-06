-- {{{ Dependencies Packages:
--	dmenu
--	dmenu-path-c
--	termite
--	font-awesome
-- }}}
--
-- Standard awesome library
local awful = require("awful")
local beautiful = require("beautiful")
local hotkeys_popup = require("awful.hotkeys_popup").widget
local naughty = require("naughty")
local wibox = require("wibox")
require("awful.autofocus")

local capi = {
	screen = screen,
}

-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
	naughty.notify({ 
		preset = naughty.config.presets.critical,
		title = "Oops, there were errors during startup!",
		text = awesome.startup_errors 
	})
end

-- Handle runtime errors after startup
do
	local in_error = false
	awesome.connect_signal("debug::error", function (err)
		-- Make sure we don't go into an endless error loop
		if in_error then return end
		in_error = true

		naughty.notify({ 
			preset = naughty.config.presets.critical,
			title = "Oops, an error happened!",
			text = tostring(err) 
		})
		in_error = false
	end)
end
-- }}}

-- {{{ Set all the shit up
local prefs = require("prefs")
prefs.init()
-- homebrew modules
local widgets = require("widgets")
local helperutils = require("utils").helper
local widgetutils = require("utils").widget

-- }}}

-- Table of layouts to cover with awful.layout.inc, order matters.
awful.layout.layouts = {
		awful.layout.suit.floating,
		awful.layout.suit.tile,
		awful.layout.suit.tile.left,
		awful.layout.suit.tile.bottom,
		awful.layout.suit.tile.top,
		awful.layout.suit.fair,
		awful.layout.suit.fair.horizontal,
		awful.layout.suit.spiral,
		awful.layout.suit.spiral.dwindle,
		awful.layout.suit.max,
		awful.layout.suit.max.fullscreen,
		awful.layout.suit.magnifier,
		awful.layout.suit.corner.nw,
		-- awful.layout.suit.corner.ne,
		-- awful.layout.suit.corner.sw,
		-- awful.layout.suit.corner.se,
}

-- {{{ Wibar

-- Create a wibox for each screen and add it
awful.screen.connect_for_each_screen(function(s)
	-- Wallpaper
	helperutils.set_wallpaper(s)

	-- Each screen has its own tag table.
	if prefs.config.tags_for_screen[s.index] ~= nil then
		awful.tag(prefs.config.tags_for_screen[s.index], s, prefs.config.preferred_layout)
	else
		awful.tag({ "1", "2", "3", "4", "5", "6", "7", "8", "9" }, s, prefs.config.preferred_layout)
	end

	-- Create an imagebox widget which will contains an icon indicating which layout we're using.
	-- We need one layoutbox per screen.
	s.dynamictag = prefs.widgets.dynamictag()
	s.mylayoutbox = awful.widget.layoutbox(s)
	s.mylayoutbox:buttons(prefs.buttons.layout)
	-- Create a taglist widget
	s.mytaglist = awful.widget.taglist(
		s, 
		awful.widget.taglist.filter.all, 
		prefs.buttons.taglist, 
		nil, 
		prefs.taglist.remove_shape_from_text_tags
	)

	-- Create a tasklist widget
	s.mytasklist = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, prefs.buttons.tasklist)

	-- Create the wibox
	s.mywibox = awful.wibar({ position = "top", height = beautiful.main_wibar_height, screen = s })

	--local widgets = require("widgets")
	-- Add widgets to the wibox
	s.mywibox:setup {
		layout = wibox.layout.align.horizontal,
		{-- Left widgets
			layout = wibox.layout.fixed.horizontal,
			s == capi.screen.primary and prefs.widgets.mainmenu_launcher or nil,
			s.mytaglist,
			s.dynamictag,
		},
		s.mytasklist, -- Middle widget
		{-- Right widgets
			layout = wibox.layout.fixed.horizontal,
			--widgets.volumecontrol(),
			widgetutils.pacman(),
			--widgetutils.volume(),
			prefs.widgets.virshcontrol(),
			prefs.widgets.keyboard_layout,
			widgetutils.clock(),
			widgetutils.systray(),
			s.mylayoutbox,
		},
	}
end)
-- }}}

-- check if we've set our background using feh before and if so eval it
if awful.util.file_readable("~/.fehbg") then 
	awful.spawn("~/.fehbg")
end

