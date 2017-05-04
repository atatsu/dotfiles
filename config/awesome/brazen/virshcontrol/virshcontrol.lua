----------------------------------------------------------------------------
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
local markup = brazenutils.markup

local signalhandlers = require(path .. "signalhandlers")
local virshdomain = require(path .. "virshdomain")

local capi = {
	mouse = mouse,
}

local VirshControl = {}
VirshControl.__index = VirshControl
VirshControl.__tostring = function () return "virshcontrol" end

-- {{{ Properties
local properties = {
	checkbox_props = beautiful.virshcontrol_checkbox_props or {},
	checkbox_props_active = beautiful.virshcontrol_checkbox_props_active or {},
	checkbox_props_hover = beautiful.virshcontrol_checkbox_props_hover or {},

	domain_window_close_on_mouse_leave = (function ()
		if beautiful.virshcontrol_domain_window_close_on_leave ~= nil then
			return beautiful.virshcontrol_domain_window_close_on_leave
		end
		return true
	end)(),
	domain_window_row_height = beautiful.virshcontrol_domain_window_row_height or 24,
	domain_window_row_margins = beautiful.virshcontrol_domain_window_row_margins or 5,  -- left, right, top, bottom
	domain_window_width = beautiful.virshcontrol_domain_window_width or 150,

	icon_glyph = beautiful.virshcontrol_icon_glyph or "vc",
	icon_color_normal = beautiful.virshcontrol_icon_color_normal or beautiful.fg_normal or "#ff0000",
	icon_color_active = beautiful.virshcontrol_icon_color_active or beautiful.fg_urgent or "#ff0000",
	icon_margins = beautiful.virshcontrol_icon_margins or { left = 1, right = 1 },

	label_color = beautiful.virshcontrol_label_color or "",
	label_color_active = beautiful.virshcontrol_label_color_active or "",
	label_color_hover = beautiful.virshcontrol_label_color_hover or "",
	label_network_glyph = beautiful.virshcontrol_label_network_glyph or "network: ",

	notification_accent_color = beautiful.virshcontrol_notification_accent_color or beautiful.taglist_bg_focus or "#ff0000",

	start_destroy_confirm_glyph = beautiful.virshcontrol_start_destroy_confirm_glyph or "o",
	start_destroy_confirm_glyph_color = beautiful.virshcontrol_start_destroy_confirm_glyph_color or beautiful.fg_urgent or "#ff0000",
	start_destroy_confirm_timeout = beautiful.virshcontrol_start_destroy_confirm_timeout or 3,
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
	_[self].store.active_domains = {}

	local margins = self:get_icon_margins() or {}
	self:setup{
		id = "widgets",
		layout = wibox.layout.fixed.horizontal,
		{
			layout = wibox.container.margin,
			left = margins.left or 0,
			right = margins.right or 0,
			{
				id = "icon",
				align = "center",
				--text = self:get_icon_glyph(),
				markup = markup{ text = self:get_icon_glyph(), color = self:get_icon_color_normal() },
				valign = "center",
				widget = wibox.widget.textbox
			}
		}
	}

	-- make it so we can just key into our first level widget
	-- to query for any child, no matter how deeply nested
	setmetatable(self.widgets, {
		__index = function (table, key)
			local children = self:get_children_by_id(key)
			if #children > 0 then
				return children[1]
			end
		end
	})

	local icon = self.widgets["icon"]
	icon:buttons(awful.util.table.join(
		-- left-click
		awful.button({ }, 1, function ()
			self:toggle_domain_window()
		end)
	))

	_[self].setup.domain_window()
	signalhandlers.connect_own(self)
	return self
end

function VirshControl:activate_icon ()
	local glyph = self:get_icon_glyph()
	local color = self:get_icon_color_active()
	local _markup = markup{ text = glyph, color = color }
	self.widgets["icon"]:set_markup(_markup)
end

function VirshControl:deactivate_icon ()
	local glyph = self:get_icon_glyph()
	local color = self:get_icon_color_normal()
	local _markup = markup{ text = glyph, color = color }
	self.widgets["icon"]:set_markup(_markup)
end

function VirshControl:add_active_domain (domain)
	local active_domains = _[self].store.active_domains
	active_domains[#active_domains + 1] = domain
	self:emit_signal("domain::count::changed", #active_domains)
end

function VirshControl:remove_active_domain (domain)
	local active_domains = _[self].store.active_domains
	local index
	for i, v in ipairs(active_domains) do
		if v == domain then
			index = i
		end
	end
	if not index then
		print("attempted to remove active domain but domain didn't match any in store")
		return
	end

	table.remove(active_domains, index)
	self:emit_signal("domain::count::changed", #active_domains)
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
			local domain_window_row_height = self:get_domain_window_row_height()
			local domain_window_row_margins = self:get_domain_window_row_margins()
			local base_height = domain_window_row_height * #conf

			local top, bottom
			if type(domain_window_row_margins) == "table" then
				top, bottom = domain_window_row_margins.top or 0, domain_window_row_margins.bottom or 0
			else
				top, bottom = domain_window_row_margins, domain_window_row_margins
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
				local margins = self:get_domain_window_row_margins()
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
			local _p = _[self]

			if _p.store.domain_window then return end

			local instance = wibox{
				height = _p.calc.domain_window_height(),
				width = self:get_domain_window_width(),
				ontop = true,
				visible = false
			}
			instance:setup{
				id = "outer",
				widget = wibox.layout.flex.vertical,
			}

			for i, v in ipairs(_p.store.virsh_config) do
				local left, right, top, bottom = _p.calc.harmonious_margins(i)
				local domain = virshdomain(v, {
					checkbox_props = self:get_checkbox_props(),
					checkbox_props_active = self:get_checkbox_props_active(),
					checkbox_props_hover = self:get_checkbox_props_hover(),
					label_color = self:get_label_color(),
					label_color_active = self:get_label_color_active(),
					label_color_hover = self:get_label_color_hover(),
					label_network_glyph = self:get_label_network_glyph(),
					start_destroy_confirm_glyph = self:get_start_destroy_confirm_glyph(),
					start_destroy_confirm_glyph_color = self:get_start_destroy_confirm_glyph_color(),
					start_destroy_confirm_timeout = self:get_start_destroy_confirm_timeout(),
				})
				-- connect to the domain's signals so we can respond to 
				-- user input and status updates
				signalhandlers.connect_domain(self, domain)

				instance.widget:add(wibox.container.margin(domain, left, right, top, bottom))
			end

			if self:get_domain_window_close_on_mouse_leave() then
				instance:connect_signal("mouse::leave", function () self:toggle_domain_window() end)
			end
			_p.store.domain_window = instance
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
