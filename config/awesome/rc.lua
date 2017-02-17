-- {{{ Dependencies Packages:
--	dmenu
--	dmenu-path-c
--	termite
--	font-awesome
-- }}}
--
-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
require("awful.autofocus")
-- Widget and layout library
local wibox = require("wibox")
-- Theme handling library
local beautiful = require("beautiful")
-- Notification library
local naughty = require("naughty")
--local menubar = require("menubar")
local hotkeys_popup = require("awful.hotkeys_popup").widget

-- homebrew modules
local helperutils = require("utils").helper
local tagutils = require("utils").tag
local widgetutils = require("utils").widget

-- Modularized settings
local prefs = require("prefs")

-- Function aliases
local exec = awful.spawn
local sexec = awful.spawn.with_shell


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
-- Key bindings
prefs.keys.setup_global()
-- Button bindings
prefs.buttons.setup_global()
-- Rules
prefs.rules.setup()
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

-- {{{ Menu
-- Create a launcher widget and a main menu
myawesomemenu = {
	{ "syela", {
		{ " tmnt", "chromium https://www.youtube.com/results?search_query=teenage+mutant+ninja+turtles&page=&utm_source=opensearch" },
		{ "netflix", "google-chrome-stable https://www.netflix.com/Kids" },
	}},
	{ "hotkeys", function() return false, hotkeys_popup.show_help end},
	{ "manual", prefs.config.terminal .. " -e man awesome" },
	{ "edit config", prefs.config.editor_cmd .. " " .. awesome.conffile },
	{ "restart", awesome.restart },
	{ "quit", function() awesome.quit() end}
}

mymainmenu = awful.menu(
	{ items = { 
		{ "awesome", myawesomemenu, beautiful.awesome_icon },
		{ "open terminal", prefs.config.terminal },
	}}
)

mylauncher = awful.widget.launcher(
	{ image = beautiful.awesome_icon, menu = mymainmenu }
)

-- Menubar configuration
--menubar.utils.terminal = prefs.config.terminal -- Set the terminal for applications that require it
-- }}}

-- Keyboard map indicator and switcher
mykeyboardlayout = awful.widget.keyboardlayout()

-- {{{ Wibar

-- Create a wibox for each screen and add it

-- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
screen.connect_signal("property::geometry", helperutils.set_wallpaper)

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
	s.mylayoutbox:buttons(awful.util.table.join(
		awful.button({ }, 1, function () awful.layout.inc( 1) end),
		awful.button({ }, 3, function () awful.layout.inc(-1) end),
		awful.button({ }, 4, function () awful.layout.inc( 1) end),
		awful.button({ }, 5, function () awful.layout.inc(-1) end))
	)
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
			mylauncher,
			s.mytaglist,
			s.mypromptbox,
		},
		s.mytasklist, -- Middle widget
		{-- Right widgets
			layout = wibox.layout.fixed.horizontal,
			widgetutils.pacman(),
			mykeyboardlayout,
			wibox.widget.systray(),
			widgetutils.clock(),
			s.mylayoutbox,
		},
	}
end)
-- }}}

-- {{{ Signals
-- Apparently with lua anonymous functions require either an assignment
-- or themselves be a parameter? Regardless, lua bitches if I don't assign
-- the called anonymous function. So.. the `signals` var isn't actually
-- used for anything.
local signals = (function()
	local classes = { ["client"] = client, ["tag"] = tag }
	for class_name, class in pairs(classes) do
		local section = prefs.signals[class_name] or {}
		for signal_name, callbacks in pairs(section) do
			for _, callback in ipairs(callbacks) do
				class.connect_signal(signal_name, callback)
			end
		end
	end
end)()
-- }}}
