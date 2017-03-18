local awful = require("awful")
local beautiful = require("beautiful")
local gears = require("gears")
local naughty = require("naughty")
local wibox = require("wibox")

local prefsicons = require("prefs.icons")
local widgetutils = require("utils.widget")

local capi = {
	client = client,
	screen = screen,
	mouse = mouse,
}

local M = {}

function M.client_menu_toggle ()
	-- displays a menu of all clients
	local instance = nil

	return function ()
		if instance and instance.wibox.visible then
			instance:hide()
			instance = nil
			return
		end

		local clients = {}
		for i, c in pairs(capi.client.get()) do
			local hidden = c.hidden and prefsicons.eyeclosed or ""
			local minimized = c.minimized and prefsicons.minimized or ""
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

function _highlight_icon (w)
	w.markup = widgetutils.markup_color(w.text, beautiful.widget_icon_color or beautiful.fg_focus)
end

function _restore_icon (w)
	w.text = w._original_text
	w.markup = nil
end

function _create_icon_tag (w)
	awful.tag.add(
		w._original_text,
		{ layout = awful.layout.suit.tile, screen = awful.screen.focused(), volatile = true }
	)
end

-- Depending on the number of icons the initial build of this can 
-- be somewhat expensive. So we're going to keep hold of the final
-- result.
local instance
function M.tag_icon_picker_window_toggle (icons_per_row)
	icons_per_row = icons_per_row or 50

	return function ()
		-- Use our already generated icon display if it exists
		if instance then
			instance.visible = not instance.visible
			return
		end

		local coords = capi.mouse.coords()
		instance = wibox {
			visible = false,
			ontop = true,
			id = "main",
			--layout = wibox.layout.flex.vertical
			widget = wibox.layout.flex.vertical()
		}
		--instance = wibox({ visible = false, ontop = true })
		local s = (awful.placement.scale + awful.placement.centered)
		s(instance, { to_percent = 0.5 })

		local row = wibox.layout.flex.horizontal()
		for i, v in ipairs(prefsicons) do
			-- create a textbox with the glyph as text and
			-- then add the textbox to our horizontal layout
			local icon = wibox.widget{
				align = "center",
				text = v,
				valign = "center",
				widget = wibox.widget.textbox,
				_original_text = v
			}
			icon:connect_signal("mouse::enter", _highlight_icon)
			icon:connect_signal("mouse::leave", _restore_icon)
			icon:connect_signal("button::press", _create_icon_tag)
			row:add(icon)

			if i % icons_per_row == 0 then
				-- we're on our last icon for the row, add the horizontal
				-- layout to our main layout and then create a new one
				instance.widget:add(row)
				row = wibox.layout.flex.horizontal()
			end
		end

		-- see if we need to add some spacer textboxes so that the last row
		-- is spaced evenly with the others
		for i = 1, (icons_per_row - #row.children) do
			icon = wibox.widget{ 
				text = prefsicons[1], 
				visible = false,
				widget = wibox.widget.textbox 
			}
			row:add(icon)
		end
		instance.widget:add(row)

		instance:connect_signal("mouse::leave", function () instance.visible = false end)
		instance.visible = true
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
