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
-- Themes define colours, icons, font and wallpapers.
beautiful.init(awful.util.get_themes_dir() .. "zenburn/theme.lua")

-- Most `prefs` rely on `beautiful` and as such can't be imported until
-- after initialization
local prefs = require("prefs")
-- homebrew modules
local helperutils = require("utils").helper
local tagutils = require("utils").tag
local widgetutils = require("utils").widget

prefs.init()
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
	if tagutils.tags_for_screen[s.index] ~= nil then
		awful.tag(tagutils.tags_for_screen[s.index], s, prefs.config.preferred_layout)
	else
		awful.tag({ "1", "2", "3", "4", "5", "6", "7", "8", "9" }, s, prefs.config.preferred_layout)
	end

	-- Create a promptbox for each screen
	s.mypromptbox = awful.widget.prompt()
	-- Create an imagebox widget which will contains an icon indicating which layout we're using.
	-- We need one layoutbox per screen.
	s.mylayoutbox = awful.widget.layoutbox(s)
	s.mylayoutbox:buttons(prefs.buttons.layout)
	-- Create a taglist widget
	s.mytaglist = awful.widget.taglist(s, awful.widget.taglist.filter.all, prefs.buttons.taglist)

	-- Create a tasklist widget
	s.mytasklist = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, prefs.buttons.tasklist)

	-- Create the wibox
	s.mywibox = awful.wibar({ position = "top", screen = s })

	-- Add widgets to the wibox
	s.mywibox:setup {
		layout = wibox.layout.align.horizontal,
		{-- Left widgets
			layout = wibox.layout.fixed.horizontal,
			prefs.widgets.mainmenu_launcher,
			s.mytaglist,
			s.mypromptbox,
		},
		s.mytasklist, -- Middle widget
		{-- Right widgets
			layout = wibox.layout.fixed.horizontal,
			widgetutils.pacman(),
			prefs.widgets.keyboard_layout,
			wibox.widget.systray(),
			widgetutils.clock(),
			s.mylayoutbox,
		},
	}
end)
-- }}}
