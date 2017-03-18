local awful = require("awful")
local beautiful = require("beautiful")
local gears = require("gears")
local naughty = require("naughty")

local icons = require("prefs.icons")

local capi = {
	client = client,
	screen = screen,
}

local M = {}

function M.client_menu_toggle ()
	-- displays a menu of all clients
	local instance = nil

	return function ()
		if instance and instance.wibox.visible then
			instance:hide()
			instance = nil
		else
			local clients = {}
			for i, c in pairs(capi.client.get()) do
				local hidden = c.hidden and icons.eyeclosed or ""
				local minimized = c.minimized and icons.minimized or ""
				clients[i] = {
					hidden .. " " .. minimized .. " " .. c.name,
					function ()
						c.first_tag:view_only()
						c.hidden = false
						capi.client.focus = c
					end,
					c.icon
				}
			end
			instance = awful.menu({ items = clients, theme = { width = 200 } })
			instance:show()
		end
	end
end

function M.notify_normal (title, text)
	naughty.notify({
		preset = naughty.config.presets.normal,
		title = title,
		text = text
	})
end

function M.set_wallpaper (s)
	-- Wallpaper
	if beautiful.wallpaper then
		local wallpaper = beautiful.wallpaper
		-- If wallpaper is a function, call it with the screen
		if type(wallpaper) == "function" then
			wallpaper = wallpaper(s)
		end
		gears.wallpaper.maximized(wallpaper, s, true)
	end
end

return M
