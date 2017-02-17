local awful = require("awful")
local beautiful = require("beautiful")
local wibox = require("wibox")

local helperutils = require("utils").helper

local is_setup = false

local classes = { 
	["client"] = client, 
	["tag"] = tag, 
	["screen"] = screen,
}

local M
M = {
	init = function ()
		if is_setup then return end
		is_setup = true

		for class_name, class in pairs(classes) do
			local section = M[class_name] or {}
			for signal_name, callbacks in pairs(section) do
				for _, callback in ipairs(callbacks) do
					class.connect_signal(signal_name, callback)
				end
			end
		end
	end
}

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
			if awful.layout.get(c.screen) ~= awful.layout.suit.floating then
				awful.titlebar.hide(c)
			end

			-- No clients should be shown in the tasklist
			c.skip_taskbar = true
		end
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
		end
	},
	["request::titlebars"] = {
		function (c)
			-- buttons for the titlebar
			local buttons = awful.util.table.join(
				awful.button({ }, 1, function()
					client.focus = c
					c:raise()
					awful.mouse.client.move(c)
				end),
				awful.button({ }, 3, function()
					client.focus = c
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
					awful.titlebar.widget.floatingbutton (c),
					awful.titlebar.widget.maximizedbutton(c),
					awful.titlebar.widget.stickybutton	 (c),
					awful.titlebar.widget.ontopbutton		 (c),
					awful.titlebar.widget.closebutton		 (c),
					layout = wibox.layout.fixed.horizontal()
				},
				layout = wibox.layout.align.horizontal
			}
		end
	},
	["mouse::enter"] = {
		function (c)
			if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier and awful.client.focus.filter(c) then
				client.focus = c
			end
		end
	},
	focus = {
		function (c)
			c.border_color = beautiful.border_focus
		end
	},
	unfocus = {
		function (c)
			c.border_color = beautiful.border_normal
		end
	},
}

M.tag = {
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
