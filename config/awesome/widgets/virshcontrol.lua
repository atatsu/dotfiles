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
-- @classmod widgets.virshcontrol
----------------------------------------------------------------------------
local awful = require("awful")
local base = require("wibox.widget.base")
local beautiful = require("beautiful")
local util = require("awful.util")
local wibox = require("wibox")

local widgetutil = require("widgets.util")

local VirshControl = {}
VirshControl.__index = VirshControl

local properties = {
	icon_glyph = beautiful.virshcontrol_icon_glyph or "vc",
	icon_color_normal = beautiful.virshcontrol_icon_color_normal or beautiful.fg_normal,
	icon_color_active = beautiful.virshcontrol_icon_color_active or beautiful.fg_urgent,
	icon_margins = beautiful.virshcontrol_icon_margins or {
		left = 1,
		right = 1
	}
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

function _get_buttons (vc)
	return awful.util.table.join(
	)
end

--- Create a new virsch control widget.
-- @treturn VirshControl A new VirshControl instance.
function VirshControl.new (args)
	local w = base.make_widget(nil, nil, { enable_properties = true })
	util.table.crush(w._private, args or {})

	local widget = wibox.layout.fixed.horizontal()
	util.table.crush(w, widget, false)

	local self = setmetatable(w, VirshControl)
	util.table.crush(self._private, args or {})

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
				markup = widgetutil.markup(self:get_icon_glyph(), self:get_icon_color_normal()),
				valign = "center",
				widget = wibox.widget.textbox
			}
		}
	}

	local icon = self.row.margin.icon
	icon:buttons(_get_buttons(self))

	return self
end

return setmetatable(VirshControl, {
	__call = function (cls, ...)
		return cls.new(...)
	end
})
