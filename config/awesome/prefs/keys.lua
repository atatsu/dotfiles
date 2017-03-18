local awful = require("awful")
local beautiful = require("beautiful")
local gears = require("gears")
local hotkeys_popup = require("awful.hotkeys_popup").widget

local helperutils = require("utils.helper")
local screenutils = require("utils.screen")
local widgets = require("prefs.widgets")
local config = require("prefs.config")

local modkey = config.modkey
local sexec = awful.spawn.with_shell

local capi = {
	awesome = awesome,
	client = client,
	screen = screen,
}

local is_setup = false

local M
M = {
	init = function ()
		if is_setup then return end
		is_setup = true

		root.keys(M.global)
	end
}

M.global = (function ()
	local keys = awful.util.table.join(
		awful.key(
			{ modkey, }, 
			"b", 
			function () 
				local c = capi.client.focus
				capi.client.focus.border_color = beautiful.border_focus
				gears.timer.weak_start_new(config.focus_highlight_fade, function ()
					if not c then return end
					c.border_color = beautiful.border_normal
				end)
			end,
			{ description="highlight focused client", group="screen" }
		),
		awful.key(
			{ modkey, }, 
			"Right", 
			function () 
				local screen = awful.screen.focused()
				local tag = screen.selected_tag
				local index = screen.index + 1 <= capi.screen:count() and screen.index + 1 or 1
				local swap_with = screenutils.get_by_index(index)
				--screen:swap(swap_with)
				tag.screen = swap_with
				tag:view_only()
				awful.screen.focus(swap_with)
			end, 
			{ description = "move tag to the next screen", group = "screen" }
		),
		awful.key(
			{ modkey },
			"Left",
			function () 
				local screen = awful.screen.focused()
				local tag = screen.selected_tag
				local index = screen.index - 1 > 0 and screen.index - 1 or 1
				local move_to = screenutils.get_by_index(index)
				tag.screen = move_to
				tag:view_only()
				awful.screen.focus(move_to)
			end,
			{ description = "move tag to the previous screen", group = "tag" }
		),
		awful.key(
			{ modkey, }, 
			"k",
			function ()
				local screen = awful.screen.focused()
				local index = screen.index - 1 >= 1 and screen.index - 1 or capi.screen:count()
				local swap_with = screenutils.get_by_index(index)
				screen:swap(swap_with)
			end, 
			{ description = "swap with previous screen by index", group = "screen" }
		),
		awful.key({ modkey, }, "s", hotkeys_popup.show_help, { description="show help", group="awesome" }),
		awful.key({ modkey, }, "p", awful.tag.viewprev, { description = "view previous", group = "tag" }),
		awful.key(
			{ modkey, }, 
			"n", 
			function ()
				local screen = awful.screen.focused()
				if screen.selected_tag == nil then
					screen.tags[1]:view_only()
				end
				awful.tag.viewnext(screen)
			end,
			{ description = "view next", group = "tag" }
		),
		awful.key({ modkey, }, "Escape", awful.tag.history.restore, { description = "go back", group = "tag" }),
		awful.key({ modkey, }, "j", function () awful.client.focus.byidx( 1) end, { description = "focus next by index", group = "client" }),
		awful.key({ modkey, }, "k", function () awful.client.focus.byidx(-1) end, { description = "focus previous by index", group = "client" }),
		awful.key({ modkey, }, "w", function () widgets.mainmenu:show() end, { description = "show main menu", group = "awesome" }),
		awful.key({ modkey, "Shift" }, "w", helperutils.client_menu_toggle(), { description = "show a menu of all clients", group = "awesome" }),

		-- Layout manipulation
		awful.key({ modkey, "Shift" }, "j", function () awful.client.swap.byidx(	1) end, { description = "swap with next client by index", group = "client" }),
		awful.key({ modkey, "Shift" }, "k", function () awful.client.swap.byidx( -1) end, { description = "swap with previous client by index", group = "client" }),
		awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end, { description = "focus the next screen", group = "screen" }),
		awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end, { description = "focus the previous screen", group = "screen" }),
		awful.key({ modkey, }, "u", awful.client.urgent.jumpto, { description = "jump to urgent client", group = "client" }),
		awful.key(
			{ modkey, }, 
			"Tab",
			function ()
				awful.client.focus.history.previous()
				if capi.client.focus then
					capi.client.focus:raise()
				end
			end,
			{ description = "go back", group = "client" }
		),

		-- Standard program
		awful.key({ modkey, }, "`", function () widgets.termleaf:toggle() end),
		awful.key({ modkey, }, "Return", function () awful.spawn(config.terminal) end, { description = "open a terminal", group = "launcher" }),
		awful.key({ modkey, "Shift" }, "r", capi.awesome.restart, { description = "reload awesome", group = "awesome" }),
		awful.key({ modkey, "Shift" }, "q", capi.awesome.quit, { description = "quit awesome", group = "awesome" }),
		awful.key({ modkey, }, "l", function () awful.tag.incmwfact( 0.05) end, { description = "increase master width factor", group = "layout" }),
		awful.key({ modkey, }, "h", function () awful.tag.incmwfact(-0.05) end, { description = "decrease master width factor", group = "layout" }),
		awful.key({ modkey, "Shift" }, "h", function () awful.tag.incnmaster( 1, nil, true) end, { description = "increase the number of master clients", group = "layout" }),
		awful.key({ modkey, "Shift" }, "l", function () awful.tag.incnmaster(-1, nil, true) end, { description = "decrease the number of master clients", group = "layout" }),
		awful.key({ modkey, "Control" }, "h", function () awful.tag.incncol( 1, nil, true) end, { description = "increase the number of columns", group = "layout" }),
		awful.key({ modkey, "Control" }, "l", function () awful.tag.incncol(-1, nil, true) end, { description = "decrease the number of columns", group = "layout" }),
		awful.key({ modkey, "Shift" }, "g", function () awful.tag.incgap(1) end, { description = "increase the spacing between clients", group = "layout" }),
		awful.key({ modkey, "Control" }, "g", function () awful.tag.incgap(-1) end, { description = "decrease the spacing between clients", group = "layout" }),
		awful.key({ modkey, }, "space", function () awful.layout.inc( 1) end, { description = "select next", group = "layout" }),
		awful.key({ modkey, "Shift" }, "space", function () awful.layout.inc(-1) end, { description = "select previous", group = "layout" }),
		awful.key(
			{ modkey, "Control" }, 
			"n",
			function ()
				local c = awful.client.restore()
				-- Focus restored client
				if c then
					capi.client.focus = c
					c:raise()
				end
			end,
			{ description = "restore minimized", group = "client" }),

		-- Prompt
		--awful.key({ modkey }, "r", function () awful.screen.focused().mypromptbox:run() end, { description = "run prompt", group = "launcher" }),
		awful.key(
			{ modkey }, 
			"r", 
			function ()
				awful.prompt.run {
					prompt = "New tag: ",
					textbox = awful.screen.focused().mypromptbox.widget,
					exe_callback = function (tag_name)
						if tag_name == "icon" then
							helperutils.tag_icon_picker_window_toggle(30)()
							return
						end
						if tag_name == nil or tag_name:len() < 1 then 
							return
						end
						local tag = awful.tag.add(
							tag_name, 
							{ layout = awful.layout.suit.tile, screen = awful.screen.focused(), volatile = true }
						)
					end,
					history_path = awful.util.get_cache_dir() .. "/history_new_tag_name"
				}
			end,
			{ description = "create a new tag with name", group = "awesome" }
		),
		awful.key(
			{ modkey, "Control" },
			"r",
			helperutils.tag_icon_picker_window_toggle(30),
			{ description = "create a new tag with icon", group = "awesome" }
		),
		awful.key(
			{ modkey }, 
			"x",
			function ()
				awful.prompt.run {
					prompt = "Run Lua code: ",
					textbox = awful.screen.focused().mypromptbox.widget,
					exe_callback = awful.util.eval,
					history_path = awful.util.get_cache_dir() .. "/history_eval"
				}
			end,
			{ description = "lua execute prompt", group = "awesome" }
		),

		-- Menubar
		--awful.key({ modkey, "Shift" }, "m", function() menubar.show() end, { description = "show the menubar", group = "launcher" }),
		-- dmenu - mod + d
		awful.key(
			{ modkey }, 
			"d", 
			function() 
				sexec(table.concat({
					"dmenu_run -b",
					"-nf", "'" .. beautiful.fg_normal .. "'",
					"-nb", "'" .. beautiful.bg_normal .. "'",
					"-sf", "'" .. beautiful.fg_focus .. "'",
					"-sb", "'" .. beautiful.bg_focus .. "'",
					"-fn xft:terminus:style=bold:pixelsize=12",
					"-p ▶"
				}, " ")) 
			end,
			{ description = "spawn dmenu", group = "launcher" }
		)
	)

	for i = 1, 9 do
		keys = awful.util.table.join(
			keys,
			-- View tag only.
			awful.key(
				{ modkey }, 
				"#" .. i + 9,
				function ()
					local screen = awful.screen.focused()
					local tag = screen.tags[i]
					if tag then
						tag:view_only()
					end
				end,
				{ description = "view tag #"..i, group = "tag" }
			),
			-- Toggle tag display.
			awful.key(
				{ modkey, "Control" }, 
				"#" .. i + 9,
				function ()
					local screen = awful.screen.focused()
					local tag = screen.tags[i]
					if tag then
						awful.tag.viewtoggle(tag)
					end
				end,
				{ description = "toggle tag #" .. i, group = "tag" }
			),
			-- Move client to tag.
			awful.key(
				{ modkey, "Shift" }, 
				"#" .. i + 9,
				function ()
					if capi.client.focus then
						local tag = capi.client.focus.screen.tags[i]
						if tag then
							capi.client.focus:move_to_tag(tag)
						end
				 end
				end,
				{ description = "move focused client to tag #"..i, group = "tag" }
			),
			-- Toggle tag on focused client.
			awful.key(
				{ modkey, "Control", "Shift" }, 
				"#" .. i + 9,
				function ()
					if capi.client.focus then
						local tag = capi.client.focus.screen.tags[i]
						if tag then
							capi.client.focus:toggle_tag(tag)
						end
					end
				end,
				{ description = "toggle focused client on tag #" .. i, group = "tag" }
			)
		)
	end

	return keys
end)()

M.client = awful.util.table.join(
	awful.key(
		{ modkey,	}, 
		"f",
		function (c)
			c.fullscreen = not c.fullscreen
			c:raise()
		end,
		{ description = "toggle fullscreen", group = "client" }
	),
	awful.key({ modkey, "Shift" }, "c", function (c) c:kill() end, { description = "close", group = "client" }),
	awful.key({ modkey, "Control" }, "space", awful.client.floating.toggle, { description = "toggle floating", group = "client" }),
	awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end, { description = "move to master", group = "client" }),
	awful.key({ modkey, }, "o", function (c) c:move_to_screen() end, { description = "move to next screen", group = "client" }),
	awful.key({ modkey, "Shift" }, "o", function (c) c:move_to_screen(c.screen.index-1) end, { description = "move to previous screen", group = "client" }),
	awful.key({ modkey, }, "t", awful.titlebar.toggle, { description = "toggle titlebar", group = "client" }),
	awful.key({ modkey, "Shift" }, "t", function (c) c.ontop = not c.ontop end, { description = "toggle keep on top", group = "client" }),
	awful.key({ modkey, "Shift" }, "n", function (c) c.minimized = true end , { description = "minimize", group = "client" }),
	awful.key(
		{ modkey, }, 
		"m",
		function (c)
			c.maximized = not c.maximized
			c:raise()
		end ,
		{ description = "maximize", group = "client" }
	)
)

return M
