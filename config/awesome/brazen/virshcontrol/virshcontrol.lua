-- A widget for starting/stopping virtual machines via virsh.
--
-- @usage
-- wibox.widget {
--	widget = widgets.virshcontrol
-- }
--
-- @author Nathan Lundquist (atatsu)
-- @copyright 2017 Nathan Lundquist
-- @classmod brazen.virshcontrol
----------------------------------------------------------------------------
local path = (...):match("(.-)[^%.]+$")
local awful = require("awful")
local base = require("wibox.widget.base")
local beautiful = require("beautiful")
local gears = require("gears")
local util = require("awful.util")
local wibox = require("wibox")

local brazenutils = require("brazen.utils")

local virshdomain = require(path .. "virshdomain")

local capi = {
	mouse = mouse,
}

local VirshControl = {}
VirshControl.__index = VirshControl

-- {{{ Properties
local properties = {
	checkbox_props = beautiful.virshcontrol_checkbox_props or {},
	checkbox_props_active = beautiful.virshcontrol_checkbox_props_active or {},

	domain_window_width = beautiful.virshcontrol_domain_window_width or 150,

	icon_glyph = beautiful.virshcontrol_icon_glyph or "vc",
	icon_color_normal = beautiful.virshcontrol_icon_color_normal or beautiful.fg_normal or "#ff0000",
	icon_color_active = beautiful.virshcontrol_icon_color_active or beautiful.fg_urgent or "#ff0000",
	icon_margins = beautiful.virshcontrol_icon_margins or { left = 1, right = 1 },

	label_color = beautiful.virshcontrol_label_color or {},
	label_color_active = beautiful.virshcontrol_label_color_active or {},

	notification_accent_color = beautiful.virshcontrol_notification_accent_color or beautiful.taglist_bg_focus or "#ff0000",

	row_height = beautiful.virshcontrol_row_height or 24,
	row_margins = beautiful.virshcontrol_row_margins or 5,  -- left, right, top, bottom
}

-- Create the accessors
for prop in pairs(properties) do
	VirshControl["set_" .. prop] = function (self, value)
		local changed = self._private[prop] ~= value
		self._private[prop] = value

		if changed then
			self:emit_signal("property::" .. prop)
			self:emit_signal("widget::redraw_needed")
		end
	end

	VirshControl["get_" .. prop] = function (self)
		return self._private[prop] == nil and properties[prop] or self._private[prop]
	end
end
-- }}}

-- Placeholder for the table that holds private-ish shit.
local _

function VirshControl.new (args)
	args = args or {}
	local w = base.make_widget(nil, nil, { enable_properties = true })
	util.table.crush(w._private, args)

	local widget = wibox.layout.fixed.horizontal()
	util.table.crush(w, widget, false)

	local self = setmetatable(w, VirshControl)
	util.table.crush(self._private, args or {})
	_.init(self)

	local virsh_config = args.virsh_config or {}
	args.virsh_config = nil
	_[self].store.virsh_config = virsh_config

	local margins = self:get_icon_margins() or {}
	self:setup{
		id = "row",
		layout = wibox.layout.fixed.horizontal,
		{
			id = "margin",
			layout = wibox.container.margin,
			left = margins.left or 0,
			right = margins.right or 0,
			{
				id = "icon",
				align = "center",
				--text = self:get_icon_glyph(),
				markup = brazenutils.markup{ text = self:get_icon_glyph(), color = self:get_icon_color_normal() },
				valign = "center",
				widget = wibox.widget.textbox
			}
		}
	}

	local icon = self.row.margin.icon
	icon:buttons(awful.util.table.join(
		-- left-click
		awful.button({ }, 1, function ()
			self:toggle_domain_window()
		end)
	))

	_[self].setup.domain_window()
	return self
end

function VirshControl:toggle_domain_window ()
	if not _[self].store.domain_window.visible then
		-- reposition the wibox and assign it to whatever screen
		-- the click-event happened on
		_[self].store.domain_window.screen = capi.mouse.screen
		-- The first top_right actually puts it in the top-right, but it will be covering the wibar
		-- (assuming there is a top wibar), no_offscreen fixed the overlap (again, if there was a
		-- top wibar), but ends up placing it in the top-left with its correction. Finally, 
		-- second top_right actually places it in the top-right, with no overlap over the (if present)
		-- wibar.
		local f = (awful.placement.top_right + awful.placement.no_offscreen + awful.placement.top_right)
		f(_[self].store.domain_window, { honor_workarea = true })
	end
	_[self].store.domain_window.visible = not _[self].store.domain_window.visible
end

_ = (function ()
	function init (self)

		-- {{{ Calculations

		-- Calculates height for the main wibox based on the number of 
		-- rows needed and the configured row height.
		function calculate_domain_window_height ()
			local conf = _[self].store.virsh_config
			local row_height = self:get_row_height()
			local row_margins = self:get_row_margins()
			local base_height = row_height * #conf

			local top, bottom
			if type(row_margins) == "table" then
				top, bottom = row_margins.top or 0, row_margins.bottom or 0
			else
				top, bottom = row_margins, row_margins
			end

			local margin_adjustment = top * #conf + bottom * #conf
			return base_height + margin_adjustment
		end

			-- Calculates the margins for a given row and ensures that no double 
			-- padding shit takes place. You know, when you say an item has margins of 4, 
			-- the first item has clean 4 on top, the last item has a clean 4 on bottom,
			-- and everything in between has 8 due to the items' bottom and top margins
			-- combininig.
		function calculate_harmonious_margins (current_row_index)
				local margins = self:get_row_margins()
				local num_rows = #_[self].store.virsh_config

				local left, right, top, bottom
				if type(margins) == "table" then
					left, right, top, bottom = margins.left, margins.right, margins.top, margins.bottom
				else
					left, right, top, bottom = margins, margins, margins, margins
				end

				if current_row_index == 1 then
					bottom = bottom / 2
				elseif current_row_index ~= num_rows then
					bottom = bottom / 2
					top = top / 2
				else
					top = top / 2
				end

				return left, right, top, bottom
		end
		-- }}}

		-- Create/add all the widgets that will serve as representations
		-- for our vms/domains. Also wire up signal handling.
		function populate_domain_window ()
			if _[self].store.domain_window then return end

			local instance = wibox{
				height = _[self].calc.domain_window_height(),
				width = self:get_domain_window_width(),
				ontop = true,
				visible = false
			}
			instance:setup{
				id = "outer",
				widget = wibox.layout.flex.vertical,
			}

			for i, v in ipairs(_[self].store.virsh_config) do
				local left, right, top, bottom = _[self].calc.harmonious_margins(i)
				local domain = virshdomain(v, {
					checkbox_props = self:get_checkbox_props(),
					checkbox_props_active = self:get_checkbox_props_active(),
					label_color = self:get_label_color(),
					label_color_active = self:get_label_color_active(),
				})
				domain:connect_signal("domain::start", function (d)
					print("starting domain " .. d:get_domain())
					d:check()
				end)
				domain:connect_signal("domain::destroy", function (d)
					print("stopping domain " .. d:get_domain())
					d:uncheck()
				end)
				instance.widget:add(wibox.container.margin(domain, left, right, top, bottom))
			end

			instance:connect_signal("mouse::leave", function () self:toggle_domain_window() end)
			_[self].store.domain_window = instance
		end

		_[self] = {
			calc = {
				domain_window_height = calculate_domain_window_height,
				harmonious_margins = calculate_harmonious_margins,
			},
			setup = {
				domain_window = populate_domain_window,
			},
			store = { },
		}
	end

	return {
		init = init,
	}
end)()

return setmetatable(VirshControl, {
	__call = function (cls, ...)
		return cls.new(...)
	end
})
