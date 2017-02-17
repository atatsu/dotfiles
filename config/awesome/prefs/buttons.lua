local awful = require("awful")

local config = require("prefs.config")

local modkey = config.modkey

local M = {}

root.buttons(awful.util.table.join(
	-- TODO: mymainmenu
	--awful.button({ }, 3, function () mymainmenu:toggle() end),
	awful.button({ }, 4, awful.tag.viewnext),
	awful.button({ }, 5, awful.tag.viewprev)
))

M.client = awful.util.table.join(
	awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
	awful.button({ modkey }, 1, awful.mouse.client.move),
	awful.button({ modkey }, 3, awful.mouse.client.resize)
)

return M
