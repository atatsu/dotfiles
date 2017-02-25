local awful = require("awful")
local beautiful = require("beautiful")
local gears = require("gears")
local naughty = require("naughty")
local wibox = require("wibox")

local helperutils = require("utils").helper
local config = require("prefs.config")

local capi = {
	client = client,
	tag = tag,
	screen = screen,
}

local is_setup = false

local M
M = {
	init = function ()
		if is_setup then return end
		is_setup = true

		for class_name, class in pairs(capi) do
			local section = M[class_name] or {}
			for signal_name, callbacks in pairs(section) do
				for _, callback in ipairs(callbacks) do
					class.connect_signal(signal_name, callback)
				end
			end
		end
	end
}

function get_tiled_visible_clients (tag)
	local tiled_visible = {}
	for _, c in ipairs(tag:clients()) do
		if not c.floating and not c.minimized and not c.hidden and not c.maximized then
			tiled_visible[#tiled_visible+1] = c
		end
	end
	return tiled_visible
end

-- enable useless_gap when there is more than one client tagged
-- and disable it when there is only one or none
function manage_useless_gap (client_or_tag)
	local tag
	if type(client_or_tag) == "client" then
		tag = client_or_tag.valid and client_or_tag.first_tag
	elseif type(client_or_tag) == "tag" then
		tag = client_or_tag
	else
		naughty.notify({
			preset = naughty.config.presets.normal,
			title = "Unhandled thing",
			text = type(client_or_tag)
		})
	end
	if tag == nil then 
		-- when clients close some of their signals get emitted but there isn't
		-- actually a valid client to do anything with (and the tag's "untagged" signal
		-- will still fire so it doesn't matter) so we get `nil` here and can 
		-- just forget about it
		return
	end

	local tiled_visible = get_tiled_visible_clients(tag)

	if #tiled_visible > 1 then
		-- only set gap to theme if there isn't already a value > 0
		-- so we don't fuck up any tags that had some manual gap adjustments
		tag.gap = tag.gap > 0 and tag.gap or beautiful.useless_gap
	else
		tag.gap = 0
	end
end

M.client = {
	manage = {
		function (c)
			-- Set the windows at the slave,
			-- i.e. put it at the end of others instead of setting it master.
			-- if not awesome.startup then awful.client.setslave(c) end
			if awesome.startup and not c.size_hints.user_position and not c.size_hints.program_position then
					-- Prevent clients from being unreachable after screen count changes.
					awful.placement.no_offscreen(c)
			end

			-- if the layout isn't a floating one hide the titlebar
			-- but only of the client didn't spawn floating (dialogs)
			if awful.layout.get(c.screen) ~= awful.layout.suit.floating and not c.floating then
				awful.titlebar.hide(c)
			end

			-- No clients should be shown in the tasklist
			c.skip_taskbar = true
		end,
	},
	unmanage = {
		-- check if the client has a timer attached to it (from the 'focus' signal) and if so
		-- stop it
		function (c)
			if not c._timer or not c._timer.started then
				return
			end

			c._timer:stop()
		end,
	},
	["property::floating"] = {
		manage_useless_gap,
	},
	["property::maximized"] = {
		manage_useless_gap,
	},
	["property::minimized"] = {
		-- We want minimized clients to show up in the taskbar...
		-- else how the fuck are we supposed to know there's a 
		-- fuckin' minimized client
		function (c)
			if c.minimized then
				c.skip_taskbar = false
			else
				c.skip_taskbar = true
			end
		end,
		-- update useless_gap
		manage_useless_gap
	},
	["request::titlebars"] = {
		function (c)
			-- buttons for the titlebar
			local buttons = awful.util.table.join(
				awful.button({ }, 1, function()
					capi.client.focus = c
					c:raise()
					awful.mouse.client.move(c)
				end),
				awful.button({ }, 3, function()
					capi.client.focus = c
					c:raise()
					awful.mouse.client.resize(c)
				end)
			)

			awful.titlebar(c) : setup {
				{ -- Left
					awful.titlebar.widget.iconwidget(c),
					buttons = buttons,
					layout	= wibox.layout.fixed.horizontal
				},
				{ -- Middle
					{ -- Title
						align  = "center",
						widget = awful.titlebar.widget.titlewidget(c)
					},
					buttons = buttons,
					layout	= wibox.layout.flex.horizontal
				},
				{ -- Right
					awful.titlebar.widget.floatingbutton(c),
					awful.titlebar.widget.maximizedbutton(c),
					awful.titlebar.widget.stickybutton(c),
					awful.titlebar.widget.ontopbutton(c),
					awful.titlebar.widget.closebutton(c),
					layout = wibox.layout.fixed.horizontal()
				},
				layout = wibox.layout.align.horizontal
			}
			awful.titlebar(c, { position = "top", size = beautiful.titlebar_height })
		end
	},
	["mouse::enter"] = {
		function (c)
			if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier and awful.client.focus.filter(c) then
				capi.client.focus = c
			end
		end
	},
	focus = {
		function (c)
			-- always check that it's valid in case it was closed during the execution
			-- of this callback
			if not c.valid then return end
			c.border_color = beautiful.border_focus
			-- unhighlight the client after a delay
			if not c.valid then return end
			c._timer = gears.timer.weak_start_new(config.focus_highlight_fade, function () 
				-- client may have been closed before timer expired so check
				--if not c then return end
				if not c.valid then return end
				c.border_color = beautiful.border_normal
			end)
		end
	},
	unfocus = {
		function (c)
			c.border_color = beautiful.border_normal
		end
	},
}

M.tag = {
	["tagged"] = {
		manage_useless_gap,
	},
	["untagged"] = {
		manage_useless_gap,
	},
	["property::layout"] = {
		-- hide titlebars for clients if layout isn't floating
		function (t)
			local floating = t.layout == awful.layout.suit.floating
			for _, c in ipairs(t:clients()) do
				if floating then
					awful.titlebar.show(c)
				else
					awful.titlebar.hide(c)
				end
			end
		end
	},
}

M.screen = {
	["property::geometry"] = {
		-- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
		helperutils.set_wallpaper,
	}
}

return M
