local awful = require("awful")

local utils = require("utils")

local config = require("prefs.config")
local utils = require("utils")
local widgets = require("prefs.widgets")

local modkey = config.modkey

local is_setup = false

local M
M = {
	init = function ()
		if is_setup then return end
		is_setup = true

		root.buttons(M.global)
	end
}

M.global = awful.util.table.join(
	awful.button({ }, 3, function () widgets.mainmenu:toggle() end),
	awful.button({ }, 4, awful.tag.viewnext),
	awful.button({ }, 5, awful.tag.viewprev)
)

M.client = awful.util.table.join(
	awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
	awful.button({ modkey }, 1, awful.mouse.client.move),
	awful.button({ modkey }, 3, awful.mouse.client.resize)
)

M.tasklist = awful.util.table.join(
	awful.button(
		{ }, 
		1, 
		function (c)
			if c == client.focus then
				c.minimized = true
			else
				-- Without this, the following
				-- :isvisible() makes no sense
				c.minimized = false
				if not c:isvisible() and c.first_tag then
					c.first_tag:view_only()
				end
				-- This will also un-minimize
				-- the client, if needed
				client.focus = c
				c:raise()
			end
		end
	),
	awful.button({ }, 3, utils.helper.client_menu_toggle()),
	awful.button({ }, 4, function () awful.client.focus.byidx(1) end),
	awful.button({ }, 5, function () awful.client.focus.byidx(-1) end)
)

M.taglist = awful.util.table.join(
	awful.button({ }, 1, function(t) t:view_only() end),
	-- mod + left-click
	awful.button(
		{ modkey }, 
		1, 
		function(t)
			if client.focus then
				client.focus:move_to_tag(t)
			end
		end
	),
	-- right click
	awful.button({ }, 3, awful.tag.viewtoggle),
	-- mod + right-click
	awful.button(
		{ modkey }, 
		3, 
		function(t)
			if client.focus then
				client.focus:toggle_tag(t)
			end
		end
	),
	awful.button({ }, 4, function(t) awful.tag.viewnext(t.screen) end),
	awful.button({ }, 5, function(t) awful.tag.viewprev(t.screen) end)
)

M.layout = awful.util.table.join(
	awful.button({ }, 1, function () awful.layout.inc( 1) end),
	awful.button({ }, 3, function () awful.layout.inc(-1) end),
	awful.button({ }, 4, function () awful.layout.inc( 1) end),
	awful.button({ }, 5, function () awful.layout.inc(-1) end)
)

return M
