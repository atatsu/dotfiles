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
local gears = require("gears")
local util = require("awful.util")
local wibox = require("wibox")

local widgetutil = require("widgets.util")

local VirshControl = {}
VirshControl.__index = VirshControl

local properties = {
	checkbox_props = beautiful.virshcontrol_checkbox_props or {},

	icon_glyph = beautiful.virshcontrol_icon_glyph or "vc",
	icon_color_normal = beautiful.virshcontrol_icon_color_normal or beautiful.fg_normal,
	icon_color_active = beautiful.virshcontrol_icon_color_active or beautiful.fg_urgent,
	icon_margins = beautiful.virshcontrol_icon_margins or {
		left = 1,
		right = 1
	},

	row_height = beautiful.virshcontrol_row_height or 24,
	-- left, right, top, bottom
	row_margins = beautiful.virshcontrol_row_margins or 5,
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
		-- left-click
		awful.button({ }, 1, function ()
			vc:toggle_domain_list()
		end)
	)
end

function _setup_widgets (vc)
end

--- Create a new virsch control widget.
-- @treturn VirshControl A new VirshControl instance.
function VirshControl.new (args)
	local virsh_config = args.virsh_config or {}
	args.virsh_config = nil

	local w = base.make_widget(nil, nil, { enable_properties = true })
	util.table.crush(w._private, args or {})

	local widget = wibox.layout.fixed.horizontal()
	util.table.crush(w, widget, false)

	local self = setmetatable(w, VirshControl)
	util.table.crush(self._private, args or {})
	self._private.virsh_config = virsh_config

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

function _checkbox_pressed (cb)
	cb.checked = not cb.checked
end

function _calculate_wibox_height (vc)
	local row_height = vc:get_row_height()
	local row_margins = vc:get_row_margins()
	local base_height = row_height * #vc._private.virsh_config

	local top, bottom
	if type(row_margins) == "table" then
		top, bottom = row_margins.top or 0, row_margins.bottom or 0
	else
		top, bottom = row_margins, row_margins
	end

	local margin_adjustment = top * #vc._private.virsh_config + bottom * #vc._private.virsh_config
	return base_height + margin_adjustment
end

function VirshControl:toggle_domain_list ()
	if self._domain_list then
		self._domain_list.visible = not self._domain_list.visible
		return
	end

	local instance = wibox{
		height = _calculate_wibox_height(self),
		width = 150,
		ontop = true,
		visible = false,
	}
	instance:setup{
		id = "outer",
		widget = wibox.layout.flex.vertical,
	}

	local checkbox_props = self:get_checkbox_props()
	local row_margins = self:get_row_margins()
	local left, right, top, bottom
	if type(row_margins) == "table" then
		left, right, top, bottom = row_margins.left, row_margins.right, row_margins.top, row_margins.bottom
	else
		left, right, top, bottom = row_margins, row_margins, row_margins, row_margins
	end
	for i, v in ipairs(self._private.virsh_config) do
		local row = wibox.layout.fixed.horizontal()
		local checkbox = wibox.widget{
			checked = false,
			paddings = 2,
			shape = gears.shape.circle,
			widget = wibox.widget.checkbox,
			-- theme
			border_color = checkbox_props.border_color,
			check_color = checkbox_props.check_color,
		}
		checkbox:connect_signal("button::press", _checkbox_pressed)
		row:add(checkbox)

		local label = wibox.widget{
			align = "center",
			text = v.domain or "MISCONFIGURED",
			widget = wibox.widget.textbox,
			valign = "center",
		}
		row:add(wibox.container.margin(label, 5))

		-- prevent double padding in between rows
		local prevent_double_padding_bottom, prevent_double_padding_top = bottom, top
		if i == 1 then
			prevent_double_padding_top = top
			prevent_double_padding_bottom = bottom / 2
		--elseif i == (#self._private.virsh_config - 1) then
		--  prevent_double_padding_top = top / 2
		--  prevent_double_padding_bottom = bottom
		elseif i ~= #self._private.virsh_config then
			prevent_double_padding_bottom = bottom / 2
			prevent_double_padding_top = top / 2
		else
			prevent_double_padding_top = top / 2
			prevent_double_padding_bottom = bottom
		end
		instance.outer:add(wibox.container.margin(row, left, right, prevent_double_padding_top, prevent_double_padding_bottom))
	end

	awful.placement.top_right(instance)
	awful.placement.no_offscreen(instance)
	instance:connect_signal("mouse::leave", function () self:toggle_domain_list() end)
	self._domain_list = instance
	self._domain_list.visible = true
end

return setmetatable(VirshControl, {
	__call = function (cls, ...)
		return cls.new(...)
	end
})
