----------------------------------------------------------------------------
-- A widget for easily creating tags on the fly.
--
-- @usage
-- wibox.widget {
--	widget = widgets.dynamictag
-- }
--
-- @author Nathan Lundquist (atatsu)
-- @copyright 2017 Nathan Lundquist
-- @classmod widgets.dynamictag
----------------------------------------------------------------------------
local awful = require("awful")
local base = require("wibox.widget.base")
local beautiful = require("beautiful")
local util = require("awful.util")
local wibox = require("wibox")

local widgetutil = require("widgets.util")

local capi = {
	tag = tag,
}

local DynamicTag = {}
DynamicTag.__index = DynamicTag

--- The glyphs to use for icon-style tag names.
--
-- @property glyphs
-- @tparam[opt={}] table array

local properties = {
	can_delete_non_dynamic_tags = false,

	-- widget display properties
	icon_add = "+",
	icon_delete = '-',
	icon_opacity = 0.5,
	icon_always_visible = false,

	-- new tag properties
	tag_props = {
		layout = awful.layout.suit.tile,
		volatile = true,
	},
	tag_switch_to = true,
	-- start || end
	tag_position = "end",

	-- glyph window properties
	glyph_window_margins = 10,
	glyph_window_glyphs = {"a", "b", "c"},
	glyph_window_keep_cache = true,
	glyph_window_per_row = 30,
	glyph_window_scale = 0.5,
	glyph_window_font = beautiful.font,
}

-- Create the accessors
for prop in pairs(properties) do
	DynamicTag["set_" .. prop] = function (self, value)
		local changed = self._private[prop] ~= value
		self._private[prop] = value

		if changed then
			self:emit_signal("property::" .. prop)
			self:emit_signal("widget::redraw_needed")
		end
	end

	DynamicTag["get_" .. prop] = function (self)
		return self._private[prop] == nil and properties[prop] or self._private[prop]
	end
end

function _get_buttons (dt)
	return awful.util.table.join(
		-- left-click
		awful.button({ }, 1, function ()
			dt:new_glyph_tag()
		end),
		-- right-click
		awful.button({ }, 3, function ()
			dt:new_text_tag()
		end),
		-- middle-click
		awful.button({ }, 2, function ()
		end)
	)
end

--- Create a new dynamic tag widget.
-- @treturn DynamicTag A new DynamicTag instance.
function DynamicTag.new (args)
	local w = base.make_widget(nil, nil, { enable_properties = true })
	util.table.crush(w._private, args or {})
	local self = setmetatable(w, DynamicTag)

	self._widgets = wibox.layout.fixed.horizontal()
	self._widgets:setup{
		id = "row",
		layout = wibox.layout.fixed.horizontal,
		{
			id = "margin",
			layout = wibox.container.margin,
			left = 5,
			right = 5,
			{
				id = "icon",
				align = "center",
				text = self:get_icon_add(),
				valign = "center",
				--opacity = 0,
				widget = wibox.widget.textbox
			}
		},
		{
			id = "promptbox",
			align = "center",
			text = "",
			valign = "center",
			widget = wibox.widget.textbox
		},
		_glyph_window = nil
	}

	local icon = self._widgets.row.margin.icon
	icon:buttons(_get_buttons(self))
	if not self:get_icon_always_visible() then
		icon:set_opacity(0)
		icon:connect_signal("mouse::enter", function () 
			icon:set_opacity(self:get_icon_opacity())
			icon:set_visible(1)
		end)
		icon:connect_signal("mouse::leave", function () 
			icon:set_opacity(0)
			icon:set_visible(0)
		end)
	end

	return setmetatable(self._widgets, { __index = self, __newindex = self })
end

function DynamicTag:new_text_tag ()
	local function _exe_callback (tag_name)
		if tag_name == nil or #tag_name < 1 then return end

		if tag_name == "glyph" or tag_name == "icon" then
			-- TODO
		end

		local props = self:get_tag_props() or {}
		props.screen = awful.screen.focused()
		if self:get_tag_position() == "end" then
			props.index = capi.tag:instances() + 1
		else
			props.index = -1
		end

		local tag = awful.tag.add(tag_name, props)
		tag._is_dynamic_tag = true
		if self:get_tag_switch_to() then
			tag:view_only()
		end
	end

	awful.prompt.run {
		prompt = "New tag: ",
		textbox = self._widgets.row.promptbox,
		exe_callback = _exe_callback,
		history_path = awful.util.get_cache_dir() .. "/history_dynamic_tag"
	}
end

function _create_icon_tag (w)
	local props = w._dt:get_tag_props() or {}
	props.screen = awful.screen.focused()
	if w._dt:get_tag_position() == "end" then
		props.index = capi.tag:instances() + 1
	else
		props.index = -1
	end

	local tag = awful.tag.add(w._glyph, props)
	tag._is_dynamic_tag = true
	if w._dt:get_tag_switch_to() then
		tag:view_only()
	end
end

function _highlight_icon (w)
	w.markup = widgetutil.markup(w.text, beautiful.widget_icon_color or beautiful.fg_focus)
end

function _restore_icon (w)
	w.text = w._glyph
	w.markup = nil
end

function DynamicTag:new_glyph_tag ()
	if self:get_glyph_window_keep_cache() and self._widgets._glyph_window ~= nil then 
		self._widgets._glyph_window.visible = not self._widgets._glyph_window.visible
		return 
	end

	instance = wibox{
		visible = false,
		ontop = true,
		--widget = wibox.layout.flex.vertical()
	}
	instance:setup{
		id = "outer",
		widget = wibox.container.margin,
		margins = self:get_glyph_window_margins(),
		{
			id = "inner",
			layout = wibox.layout.flex.vertical
		}
	}

	local s = (awful.placement.scale + awful.placement.centered)
	s(instance, { to_percent = 0.5 })

	local row = wibox.layout.flex.horizontal()
	local glyphs = self:get_glyph_window_glyphs()
	local glyphs_per_row = self:get_glyph_window_per_row()
	for i, v in ipairs(glyphs) do
		-- create a textbox with the glyph as text and then
		-- add the textbox to our horizontal layout
		local icon = wibox.widget{
			align = "center",
			font = self:get_glyph_window_font(),
			text = v,
			valign = "center",
			widget = wibox.widget.textbox,
			_glyph = v
		}
		icon:connect_signal("mouse::enter", _highlight_icon)
		icon:connect_signal("mouse::leave", _restore_icon)
		icon._dt = self
		icon:connect_signal("button::press", _create_icon_tag)
		row:add(icon)

		if i % glyphs_per_row == 0 then
			-- we're on our last icon for the row, add the horizontal
			-- layout to our main layout and then create a new one
			instance.outer.inner:add(row)
			row = wibox.layout.flex.horizontal()
		end
	end

	-- see if we need to add some spacer textboxes so that the last row
	-- is spaced evenly with the others
	for i = 1, (glyphs_per_row - #row.children) do
		icon = wibox.widget{ 
			text = glyphs[1], 
			visible = false,
			widget = wibox.widget.textbox 
		}
		row:add(icon)
	end
	instance.outer.inner:add(row)

	instance:connect_signal(
		"mouse::leave", 
		function () 
			instance.visible = false 
			if not self:get_glyph_window_keep_cache() then
				instance = nil
			end
		end
	)
	instance.visible = true

	if self:get_glyph_window_keep_cache() then
		self._widgets._glyph_window = instance
	end
end

return setmetatable(DynamicTag, {
	__call = function (cls, ...)
		return cls.new(...)
	end
})
