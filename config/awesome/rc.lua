-- Awesome configuration, using awesome 3.5.5-1 on Arch Linux
-- Nathan Lundquist <!-- <nathan.lundquist@gmail.com> -->

-- {{{ Dependencies
-- Packages:
--	 dmenu
--	 dmenu-path-c
--	 rxvt-unicode-256color
--	 dictd
-- }}}

-- {{{ Libaries
-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
awful.rules = require("awful.rules")
require("awful.autofocus")
-- Widget and layout library
local wibox = require("wibox")
-- Theme handling library
local beautiful = require("beautiful")
-- Notification library
local naughty = require("naughty")
local menubar = require("menubar")
-- custom widgets
local widgets = require("widgets")
local giblets = require("giblets")
-- utility functions
local utils = require("utils")
-- }}}

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
			text = err 
		})
		in_error = false
	end)
end
-- }}}

-- {{{ Variable definitions
-- Themes define colours, icons, font and wallpapers.
--beautiful.init(awful.util.getdir("config") .. "/themes/busybee/theme.lua")
beautiful.init(awful.util.getdir("config") .. "/themes/stark/theme.lua")

-- initialize custom widgets
widgets.init()

-- This is used later as the default terminal and editor to run.
terminal = "urxvt"
editor = os.getenv("EDITOR") or "nano"
editor_cmd = terminal .. " -e " .. editor

-- Valid modifiers: Any, Mod1, Mod2, Mod3, Mod4, Mod5, Shift, Lock, Control

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"

-- Function aliases
local exec = awful.util.spawn
local sexec = awful.util.spawn_with_shell
local pread = awful.util.pread

-- Table of layouts to cover with awful.layout.inc, order matters.
local layout = {
	floating = awful.layout.suit.floating,
	tile = awful.layout.suit.tile,
	left = awful.layout.suit.tile.left,
	bottom = awful.layout.suit.tile.bottom,
	top = awful.layout.suit.tile.top,
	fair = awful.layout.suit.fair,
	horizontal = awful.layout.suit.fair.horizontal,
	spiral = awful.layout.suit.spiral,
	dwindle = awful.layout.suit.spiral.dwindle,
	max = awful.layout.suit.max,
	fullscreen = awful.layout.suit.max.fullscreen,
	magnifier = awful.layout.suit.magnifier
}
local layouts = {
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
	awful.layout.suit.magnifier
}

-- placeholder for all the main widgets so they can be referenced in the 
-- keybindings and buttons if need be
local main_menu, main_promptbox, main_wibox, main_layoutbox, main_tasklist, main_taglist
local termleaf

-- table for all button bindings so they're all centralized and easy to find/modify
local buttons
buttons = {
	-- {{{ Main taglist specific buttons
	main_taglist = awful.util.table.join(
		--
		-- left-click, view the selected tag only
		awful.button({ }, 1, awful.tag.viewonly),
		--
		-- mod + left-click, move the focused client to the selected tag
		awful.button({ modkey }, 1, awful.client.movetotag),
		--
		-- right-click, toggle selection of the selected tag
		awful.button({ }, 3, awful.tag.viewtoggle),
		--
		-- mod + right-click, toggle the tag the focused client is on
		awful.button({ modkey }, 3, awful.client.toggletag),
		--
		-- scroll up, view next tag
		awful.button({ }, 4, function(t) awful.tag.viewnext(awful.tag.getscreen(t)) end),
		--
		-- scroll down, view previous tag
		awful.button({ }, 5, function(t) awful.tag.viewprev(awful.tag.getscreen(t)) end)
	),
	-- }}}

	-- {{{ Main tasklist specific buttons 
	main_tasklist = awful.util.table.join(
		--
		-- left-click, if client is not minimized, minimize it, if client
		-- is minimized, unminimize it
		awful.button({ }, 1, function (c)
			if c == client.focus then
				c.minimized = true
			else
				-- Without this, the following
				-- :isvisible() makes no sense
				c.minimized = false

				if not c:isvisible() then
					awful.tag.viewonly(c:tags()[1])
				end

				-- This will also un-minimize
				-- the client, if needed
				client.focus = c
				c:raise()
			end
		end),
		--
		-- right-click, show a pop-up menu of clients on this tag, if the pop-up is
		-- already visible, close it
		awful.button({ }, 3, function ()
			if _clients_popup then
				_clients_popup:hide()
				_clients_popup = nil
			else
				_clients_popup = awful.menu.clients({
					theme = { width = 250 }
				})
			end
		end),
		--
		-- scroll up, cycle forward through the clients on current tag, also
		-- raises the focused client so it is on top of other windows
		awful.button({ }, 4, function ()
			awful.client.focus.byidx(1)
			if client.focus then client.focus:raise() end
		end),
		--
		-- scroll down, cycle backward through the clients on the current tag, 
		-- also raises the focused client so it is on top of other windows
		awful.button({ }, 5, function ()
			awful.client.focus.byidx(-1)
			if client.focus then client.focus:raise() end
		end)
	),
	-- }}}

	-- {{{ Main layoutbox specific buttons 
	main_layoutbox = awful.util.table.join(
		--
		-- left-click, go to next layout
		awful.button({ }, 1, function () awful.layout.inc(layouts, 1) end),
		--
		-- right-click, go to previous layout
		awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
		--
		-- scroll up, go to next layout
		awful.button({ }, 4, function () awful.layout.inc(layouts, 1) end),
		--
		-- scroll down, go to previous layout
		awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end)
	),
	-- }}}

	-- {{{ Root window specific buttons
	root = awful.util.table.join(
		--
		-- right-click, toggle the main menu
		awful.button({ }, 3, function () main_menu:toggle() end),
		--
		-- scroll up, view next tag
		awful.button({ }, 4, awful.tag.viewnext),
		--
		-- scroll down, view previous tag
		awful.button({ }, 5, awful.tag.viewprev)
	),
	-- }}}

	-- {{{ Global buttons/keybindings
	globalkeys = awful.util.table.join(
		--
		-- mod + `, show terminal Leaf
		awful.key({ modkey }, "`", function() termleaf:toggle() end),
		--
		-- mod + left, go to previous tag
		awful.key({ modkey, }, "p", awful.tag.viewprev),
		--
		-- mod + right, go to next tag
		awful.key({ modkey, }, "n", awful.tag.viewnext),
		--
		-- mod + escape, go to last viewed tag
		awful.key({ modkey, }, "Escape", awful.tag.history.restore),
		--
		-- mod + j, switch focus to the next client, also raises client so that it is on top
		awful.key({ modkey, }, "j", function()
			awful.client.focus.byidx(1)
			if client.focus then client.focus:raise() end
		end),
		--
		-- mod + k, switch focus to the prev client, also raises client so that it is on top
		awful.key({ modkey, }, "k", function()
			awful.client.focus.byidx(-1)
			if client.focus then client.focus:raise() end
		end),
		--
		-- mod + w, show the main menu
		awful.key({ modkey, }, "w", function() main_menu:show() end),

		-- Layout manipulation
		--
		-- mod + shift + j, swap client forward
		awful.key({ modkey, "Shift" }, "j", function() awful.client.swap.byidx(1) end),
		--
		-- mod + shift + k, swap client backward
		awful.key({ modkey, "Shift"		}, "k", function() awful.client.swap.byidx(-1) end),
		--
		-- mod + control + j, focus next screen
		awful.key({ modkey, "Control" }, "j", function() 
			--awful.screen.focus_relative(utils.next_screen_relative())
			awful.screen.focus_relative(utils.next_screen_relative())
		end),
		--
		-- mod + control + k, focus prev screen
		awful.key({ modkey, "Control" }, "k", function() 
			awful.screen.focus_relative(utils.prev_screen_relative())
		end),
		--
		-- mod + u, jump to the client that received the urgent hint first
		awful.key({ modkey, }, "u", awful.client.urgent.jumpto),
		--
		-- mod + tab, cycle backward through the client history, also raises client so it is on top
		awful.key({ modkey, }, "Tab", function()
			awful.client.focus.history.previous()
			if client.focus then
					client.focus:raise()
			end
		end),

		-- Standard program
		--
		-- mod + enter, spawn a terminal
		awful.key({ modkey, }, "Return", function() awful.util.spawn(terminal) end),
		--
		-- mod + control + r, restart awesome
		awful.key({ modkey, "Control" }, "r", awesome.restart),
		--
		-- mod + shift + q, quit awesome
		awful.key({ modkey, "Shift" }, "q", awesome.quit),
		--
		-- mod + l, increase the master width factor by 0.05
		awful.key({ modkey, }, "l", function() awful.tag.incmwfact(0.05) end),
		--
		-- mod + h, decrease the master width factor by 0.05
		awful.key({ modkey, }, "h", function() awful.tag.incmwfact(-0.05) end),
		--
		-- mod + shift + h, increase the number of master windows by 1
		awful.key({ modkey, "Shift" }, "h", function() awful.tag.incnmaster(1) end),
		--
		-- mod + shift + l, decrease the number of master windows by 1
		awful.key({ modkey, "Shift" }, "l", function() awful.tag.incnmaster(-1) end),
		--
		-- mod + control + h, increase the number of column windows by 1
		awful.key({ modkey, "Control" }, "h", function() awful.tag.incncol(1) end),
		-- 
		-- mod + control + l, decrease the number column windows by 1
		awful.key({ modkey, "Control" }, "l", function() awful.tag.incncol(-1) end),
		--
		-- mod + space, cycle forward through the layouts
		awful.key({ modkey, }, "space", function() awful.layout.inc(layouts, 1) end),
		--
		-- mod + shift + space, cycle backward through the layouts
		awful.key({ modkey, "Shift" }, "space", function() awful.layout.inc(layouts, -1) end),
		--
		-- mod + control + n, unminimize a client
		awful.key({ modkey, "Control" }, "n", awful.client.restore),
		--
		-- mod + r, display the main promptbox on whatever screen the cursor is at and execute 
		-- the entered command
		awful.key({ modkey }, "r", function() main_promptbox[mouse.screen]:run() end),
		-- 
		-- mod + x, display the main promptbox on whatever screen the cursor is at and execute 
		-- the entered Lua code
		awful.key({ modkey }, "x",
			function ()
				awful.prompt.run(
					{ prompt = "Run Lua code: " },
					main_promptbox[mouse.screen].widget,
					awful.util.eval, 
					nil,
					awful.util.getdir("cache") .. "/history_eval"
				)
			end
		),
		--
		-- mod + d, run dmenu
		awful.key({ modkey }, "d", function()
			sexec(table.concat({
				"dmenu_run -b",
				"-nf", "'" .. beautiful.colors.white .. "'",
				"-nb", "'" .. beautiful.colors.darkgrey .. "'",
				"-sf", "'" .. beautiful.colors.orange .. "'",
				"-sb", "'" .. beautiful.colors.darkgrey .. "'",
				"-fn xft:terminus:style=bold:pixelsize=12",
				"-p ▶"
			}, " "))
		end),
		--
		-- Menubar
		--
		-- mod + shift + m, show the menubar (the one that shows .desktop entries)
		awful.key({ modkey, "Shift" }, "m", function() menubar.show() end)
	),
	-- }}}

	-- {{{ Client specific keybindings
	clientkeys = awful.util.table.join(
		--
		-- mod + f, toggle focused client fullscreen mode
		awful.key({ modkey, }, "f", function(c) c.fullscreen = not c.fullscreen end),
		-- 
		-- mod + shift + c, kill focused client
		awful.key({ modkey, "Shift" }, "c", function(c) c:kill() end),
		--
		-- mod + control + space, toggle focused client floating mode
		awful.key({ modkey, "Control" }, "space", awful.client.floating.toggle),
		-- 
		-- mod + control + enter, swap focused client with client in master window
		awful.key({ modkey, "Control" }, "Return", function(c) awful.client.setmaster(c) end),
		--
		-- mod + o, move focused client to next screen
		awful.key({ modkey, }, "o", function (c) 
			awful.client.movetoscreen(c, utils.next_screen()) 
		end),
		--
		-- mod + shift + o, move focused client to previous screen
		awful.key({ modkey, "Shift"}, "o", function (c) 
			awful.client.movetoscreen(c, utils.prev_screen()) 
		end),
		--
		-- mod + shift + t, toggle focused client state of being on top of other windows
		awful.key({ modkey, "Shift" }, "t", function (c) c.ontop = not c.ontop end),
		--
		-- mod + t, toggle focused client titlebar
		awful.key({ modkey, }, "t", awful.titlebar.toggle),
		--
		-- mod + shift + n, minimize the focused client
		awful.key({ modkey, "Shift" }, "n", function (c)
			-- The client currently has the input focus, so it cannot be
			-- minimized, since minimized clients can't have the focus.
			c.minimized = true
		end),
		-- 
		-- mod + m, toggle focused client's maximize state
		awful.key({ modkey, }, "m", function (c)
			c.maximized_horizontal = not c.maximized_horizontal
			c.maximized_vertical = not c.maximized_vertical
		end)
	),
	-- }}}

	-- {{{ Client specific buttons
	clientbuttons = awful.util.table.join(
		--
		-- left-click, focus/raise client
		awful.button({ }, 1, function(c) client.focus = c; c:raise() end),
		--
		-- mod + left-click, move client
		awful.button({ modkey }, 1, awful.mouse.client.move),
		--
		-- mod + right-click, resize client
		awful.button({ modkey }, 3, awful.mouse.client.resize)
		),
	-- }}}

	-- {{{ Bind all numbers to tags
	bind_number_to_tag = function(tag_number)
		buttons.globalkeys = awful.util.table.join(
			buttons.globalkeys,
			--
			-- mod + 1-9, view tag only.
			awful.key({ modkey }, "#" .. tag_number + 9, function()
				local screen = mouse.screen
				local tag = awful.tag.gettags(screen)[tag_number]
				if tag then
					awful.tag.viewonly(tag)
				end
			end),
			--
			-- mod + control + 1-9, toggle selection of tag.
			awful.key({ modkey, "Control" }, "#" .. tag_number + 9, function()
				local screen = mouse.screen
				local tag = awful.tag.gettags(screen)[tag_number]
				if tag then
					awful.tag.viewtoggle(tag)
				end
			end),
			--
			-- mod + shift + 1-9, move client to tag.
			awful.key({ modkey, "Shift" }, "#" .. tag_number + 9, function()
				if client.focus then
					local tag = awful.tag.gettags(client.focus.screen)[tag_number]
					if tag then
						awful.client.movetotag(tag)
					end
				end
			end),
			--
			-- mod + control + shift + 1-9, toggle tag on focused client.
			awful.key({ modkey, "Control", "Shift" }, "#" .. tag_number + 9, function()
				if client.focus then
					local tag = awful.tag.gettags(client.focus.screen)[tag_number]
					if tag then
						awful.client.toggletag(tag)
					end
				end
			end)
		)
	end,
	-- }}}
}
-- }}}

-- {{{ Wallpaper
if beautiful.wallpaper then
	for s = 1, screen.count() do
		gears.wallpaper.maximized(beautiful.wallpaper, s, true)
	end
end
-- }}}

-- {{{ Tags
-- Define a tag table which hold all screen tags.
local tags = {
	{
		names = {
			"web",
			"dev",
			"gfx",
			"steam",
			"games",
		},
		layout = {
			layout.magnifier,
			layout.tile,
			layout.floating,
			layout.left,
			layout.tile,
		}
	},
	{
		names = {
			"dev-alt",
			"vids",
			"misc",
		},
		layout = {
			layout.tile,
			layout.tile,
			layout.tile,
		}
	},
	{
		names = {
			"chat",
			"music",
			"misc",
		},
		layout = {
			layout.tile,
			layout.tile,
			layout.tile,
		}
	},
}

for scr = 1, screen.count() do
	local scr_offset = utils.screen_override(scr)
	if tags[scr] then
		tags[scr] = awful.tag(tags[scr].names, scr_offset, tags[scr].layout)
	else
		-- if additional monitors get hooked up and haven't been accounted
		-- for, just use the stock tag setup on them
		tags[scr] = awful.tag({1, 2, 3, 4, 5, 6, 7, 8, 9}, s, layout.tile)
	end
end
-- }}}

-- {{{ Util widget things
termleaf = giblets.utils.leaf("urxvt")
-- }}}

-- {{{ Menu
-- Create a laucher widget and a main menu
local awesome_menu = {
	{"manual", terminal .. " -e man awesome"},
	{"edit config", editor_cmd .. " " .. awesome.conffile},
	{"restart", awesome.restart},
	{"quit", awesome.quit}
}

main_menu = awful.menu({
	items = {
		{"awesome", awesome_menu, beautiful.awesome_icon},
		{"terminal", terminal}
	}
})

local launcher = awful.widget.launcher({
	image = beautiful.awesome_icon,
	menu = main_menu
})

-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
-- }}}

-- {{{ Wibox
-- Create a Wibox for each screen and add it
main_wibox = {}
main_promptbox = {}
main_layoutbox = {}
footer_wibox = {}
hdds = {}

-- Create a Tag for each screen
main_taglist = {}
main_taglist.buttons = buttons.main_taglist

-- Create a Tasklist for each screen
main_tasklist = {}
local _clients_popup
main_tasklist.buttons = buttons.main_tasklist

-- now actually add the wibox, layoutbox, taglist, tasklist, and promptbox to each screen
for scr = 1, screen.count() do
	local scr_offset = utils.screen_override(scr)
	-- Create a promptbox for each screen
	main_promptbox[scr_offset] = awful.widget.prompt()

	-- Create an imagebox widget which will contains an icon indicating which layout we're using.
	-- We need one layoutbox per screen.
	main_layoutbox[scr_offset] = awful.widget.layoutbox(scr_offset)
	main_layoutbox[scr_offset]:buttons(buttons.main_layoutbox)

	-- Create a taglist widget
	main_taglist[scr_offset] = awful.widget.taglist(scr, awful.widget.taglist.filter.all, main_taglist.buttons)

	-- Create a tasklist widget
	main_tasklist[scr_offset] = awful.widget.tasklist(
		scr_offset, 
		awful.widget.tasklist.filter.minimizedcurrenttags, 
		main_tasklist.buttons
	)

	-- Create the wibox(s)
	main_wibox[scr_offset] = awful.wibox({ position = "top", screen = scr, height = 12 })

	-- {{{ Main Wibox widgets
	-- Widgets that are aligned to the left
	local left_layout = wibox.layout.fixed.horizontal()
	left_layout:add(launcher)
	left_layout:add(widgets.spacer)
	left_layout:add(main_taglist[scr_offset])
	left_layout:add(widgets.spacer)
	left_layout:add(main_promptbox[scr_offset])

	-- Widgets that are aligned to the right
	local right_layout = wibox.layout.fixed.horizontal()
	-- pacman widget
	widgets.add_pacman(right_layout)
	-- disk usage widget
	--widgets.add_diskusage(right_layout)
	-- volume widget
	widgets.add_volume(right_layout)
	-- mpd widget
	widgets.add_mpd(right_layout)
	-- cpu widget
	widgets.add_cpu(right_layout)
	-- memory widget
	widgets.add_mem(right_layout)
	-- clock widget
	widgets.add_clock(right_layout)
	-- add a systray to the first screen if only one screen is available, otherwise
	-- add it to the second screen
	if (screen.count() > 1 and scr_offset == 2) or (screen.count() == 1) then
		right_layout:add(wibox.widget.systray()) 
		right_layout:add(widgets.spacer)
	end
	-- layouts widget
	right_layout:add(main_layoutbox[scr_offset])

	-- Now bring it all together (with the tasklist in the middle)
	local layout = wibox.layout.align.horizontal()
	layout:set_left(left_layout)
	layout:set_middle(main_tasklist[scr])
	layout:set_right(right_layout)

	main_wibox[scr_offset]:set_widget(layout)
	-- }}}

	-- {{{ Footer Wibox widgets
	if screen.count() > 1 and (scr_offset == 1 or scr_offset == 2) or screen.count() == 1 then
		footer_wibox[scr_offset] = awful.wibox({ position = "bottom", screen = scr, height = 12})

		hdds[scr_offset] = {}
		local footer_right = wibox.layout.fixed.horizontal()
		local footer_layout = wibox.layout.align.horizontal()
		widgets.add_hdds(footer_right, hdds[scr_offset])
		footer_layout:set_right(footer_right)
		footer_wibox[scr_offset]:set_widget(footer_layout)
	end
	-- }}}

end
-- }}}

-- {{{ Mouse bindings for the root window (when no clients are covering it up)
root.buttons(buttons.root)
-- }}}

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
	buttons.bind_number_to_tag(i)
end

-- {{{ Set keys
root.keys(buttons.globalkeys)
-- }}}

-- {{{ Rules
-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = {
	-- All clients will match this rule.
	{ 
		rule = { },
		properties = { 
			border_width = beautiful.border_width,
			border_color = beautiful.border_normal,
			focus = awful.client.focus.filter,
			raise = true,
			keys = buttons.clientkeys,
			buttons = buttons.clientbuttons 
		} 
	},
	{ 
		rule = { class = "pinentry" },
		properties = { floating = true } 
	},
	{
		rule = { class = "Xmessage" },
		properties = { floating = true },
	},
	{
		rule = { class = "Pavucontrol" },
		properties = { floating = true },
	},
	{ 
		rule = { class = "gimp" },
		properties = { floating = true } 
	},
	{
		rule = { class = "luakit" },
		properties = {
			tag = utils.get_tag_by_name("web", tags),
			switchtotag = true
		}
	},
	{
		rule = { class = "chromium" },
		properties = {
			tag = utils.get_tag_by_name("web", tags),
			switchtotag = false
		}
	},
	{
		rule = { class = "Firefox" },
		properties = {
			tag = utils.get_tag_by_name("web", tags),
			switchtotag = false
		}
	},
	{
		rule = { class = "MPlayer", instance = "vdpau" },
		properties = {
			tag = utils.get_tag_by_name("vids", tags),
			switchtotag = true
		}
	},
	{
		rule = { class = "Steam" },
		properties = {
			tag = utils.get_tag_by_name("steam", tags),
			switchtotag = false
		},
		callback = function(c)
			local tag = utils.get_tag_by_name("steam", tags)

			if c.name == "Steam - Update News" then
				awful.client.floating.set(c, true)
				c:raise()
				awful.titlebar.show(c)
			-- The trade window (and I'm sure other web windows) spawn and have
			-- no name before they are fully loaded. Float 'em!
			elseif c.name == nil or c.name == "" then
				awful.client.floating.set(c, true)
				c:raise()
				awful.titlebar.show(c)
			elseif c.name == "Steam" then
				awful.tag.setmwfact(0.75, tag)
				awful.client.setmaster(c)
				-- I'm not sure if load order affects the `setmaster` and `setslave` calls
				-- but only calling `setmaster` for the main Steam window doesn't seem to be
				-- working. Calling `swap` seems to do the trick, though.
				--c:swap(awful.client.getmaster())
			else
				awful.client.setslave(c)
			end
		end,
	},
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c, startup)
	-- Enable sloppy focus
	c:connect_signal("mouse::enter", function(c)
		if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier and awful.client.focus.filter(c) then
			client.focus = c
		end
	end)

	if not startup then
		-- Set the windows at the slave,
		-- i.e. put it at the end of others instead of setting it master.
		-- awful.client.setslave(c)

		-- Put windows in a smart way, only if they does not set an initial position.
		if not c.size_hints.user_position and not c.size_hints.program_position then
			awful.placement.no_overlap(c)
			awful.placement.no_offscreen(c)
		end
	end

	-- add a titlebar for every new "normal" or "dialog" client
	if c.type == "normal" or c.type == "dialog" or c.type == "utility" then
		utils.add_titlebar(c)
		if c.type == "utility" or c.type == "dialog" or awful.client.floating.get(c) then
			-- if the client is a "dialog" or "utility" window (like GIMPS's toolboxes) we need
			-- to skip below so its titlebar isn't toggled off for non-floating layouts
			-- additionally, skip clients that are spawned as floating (like gcolor2)
			return
		end
	end

	-- if the layout isn't a floating one hide the titlebar
	if awful.layout.get(c.screen) ~= layout.floating then
		awful.titlebar.toggle(c)
	end

	-- connect a signal so that we know when the client's floating property changes
	-- and either hide or show the titlebar depending on the floating state
	c:connect_signal("property::floating", function(c)
		-- if the layout is floating mode the titlebar will already be displayed
		-- so disregard
		if awful.layout.get(c.screen) == layout.floating then
			return
		end

		-- disregard clients that aren't "normal" or "dialog"
		if c.type ~= "normal" and c.type ~= "dialog" then
			return
		end

		awful.titlebar.toggle(c)
	end)
end)

-- Connect a signal to every tag so we know when the layout has changed. If the 
-- layout changes to a floating layout, the clients need their titlebars shown. 
-- If the layout changes to a non-floating layout, the clients need their
-- titlebars hidden.
for scr = 1, screen.count() do
	local s = utils.screen_override(scr)
	local screen_tags = awful.tag.gettags(s)
	for _, tag in ipairs(screen_tags) do
		tag:connect_signal("property::layout", function(t)
			local clients = t:clients()

			for _, c in ipairs(clients) do
				if c.type ~= "normal" or awful.client.floating.get(c) then
					-- ignore clients that aren't "normal"
					-- ignore clients that are already floating
					return
				end

				if awful.layout.get(c.screen) == layout.floating then
					awful.titlebar.show(c)
				else
					awful.titlebar.hide(c)
				end
			end
		end)
	end
end

-- affects all clients
client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}
