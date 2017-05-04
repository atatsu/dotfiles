----------------------------------------------------------------------------
-- A widget for adding/removing tags on the fly.
--
-- @usage
--
-- @author Nathan Lundquist (atatsu)
-- @copyright 2017 Nathan Lundquist
-- @classmod brazen.dynamictag
----------------------------------------------------------------------------
local path = (...):match("(.-)[^%.]+$")
local awful = require("awful")
local base = require("wibox.widget.base")
local beautiful = require("beautiful")
local util = require("awful.util")
local wibox = require("wibox")

local brazenutils = require("brazen.utils")

local markup = brazenutils.markup

local capi = {
	tag = tag,
}

local DynamicTag = {}
DynamicTag.__index = DynamicTag
DynamicTag.__tostring = function () return "dynamictag" end

-- {{{ Properties
local properties = {
	cache_glyph_window = (function () 
		if beautiful.dynamictag_glyph_window_cache ~= nil then
			return beautiful.dynamictag_glyph_window_cache
		end
		return true
	end)(),

	glyph_window_font = beautiful.dynamictag_glyph_window_font or beautiful.font or "sans 8",
	glyph_window_glyphs = beautiful.dynamictag_glyph_window_glyphs or { "a", "b", "c" },
	glyph_window_highlight_color = beautiful.dynamictag_glyph_window_highlight_color or beautiful.fg_urgent or "#ff0000",
	glyph_window_margins = beautiful.dynamictag_glyph_window_margins or 10,
	glyph_window_per_row = beautiful.dynamictag_glyph_window_per_row or 10,

	icon_glyph = beautiful.dynamictag_icon_glyph or "dt",
	icon_color_normal = beautiful.dynamictag_icon_color_normal or beautiful.fg_normal or "#ff0000",
	icon_margins = beautiful.dynamictag_icon_margins or { left = 1, right = 1 },
	icon_opacity = beautiful.dynamictag_icon_opacity or 0.5,
	icon_always_visible = beautiful.dynamictag_icon_always_visible or false,

	tag_position = beautiful.dynamictag_tag_position or "end",
	tag_props = beautiful.dynamictag_tag_props or {
		layout = awful.layout.suit.tile,
		volatile = true,
	},
	tag_switch_to = (function ()
		if beautiful.dynamictag_tag_switch_to ~= nil then 
			return beautiful.dynamic_tag_switch_to
		end
		return true
	end)(),
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
-- }}}

-- placeholder for the private-ish shit
local _

function DynamicTag.new (args)
	args = args or {}
	local w = base.make_widget(nil, nil, { enable_properties = true })
	util.table.crush(w._private, args)

	local widget = wibox.layout.fixed.horizontal()
	util.table.crush(w, widget, false)

	local self = setmetatable(w, DynamicTag)
	util.table.crush(self._private, args or {})

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
				opacity = self:get_icon_opacity(),
				text = self:get_icon_glyph(),
				valign = "center",
				widget = wibox.widget.textbox
			},
		},
		{
			id = "promptbox",
			align = "center",
			text = "",
			valign = "center",
			widget = wibox.widget.textbox
		}
	}

	-- make it so we can just key into our first level widget
	-- to query for any child, no matter how deeply nested
	brazenutils.simplify_widget_internals(self.widgets, self)

	local icon = self.widgets.icon
	icon:buttons(awful.util.table.join(
		-- left-click
		awful.button({ }, 1, function () self:new_glyph_tag() end),
		-- right-click
		awful.button({ }, 3, function () self:new_text_tag() end)
	))
	if not self:get_icon_always_visible() then
		icon:set_opacity(0)
		-- apparently updating a widget's opacity doesn't trigger a redraw
		self:emit_signal("widget::redraw_needed")
		icon:connect_signal("mouse::enter", function ()
			icon:set_opacity(self:get_icon_opacity())
			self:emit_signal("widget::redraw_needed")
		end)
		icon:connect_signal("mouse::leave", function ()
			icon:set_opacity(0)
			self:emit_signal("widget::redraw_needed")
		end)
	end

	return self
end

function DynamicTag:new_glyph_tag (glyph)
	local glyph_window = self._private.glyph_window

	if glyph_window then
		glyph_window.visible = not glyph_window.visible

		if glyph_window.visible then
			glyph_window.screen = awful.screen.focused()
			local p = (awful.placement.scale + awful.placement.centered)
			p(glyph_window, { to_percent = 0.5 })
		end

		return
	end

	glyph_window = wibox{ visible = false, ontop = true }
	glyph_window:setup{
		id = "widgets",
		widget = wibox.container.margin,
		margins = self:get_glyph_window_margins(),
		{
			id = "rows",
			layout = wibox.layout.flex.vertical
		}
	}
	brazenutils.simplify_widget_internals(glyph_window.widgets, glyph_window)

	local glyphs = self:get_glyph_window_glyphs()
	local glyphs_per_row = self:get_glyph_window_per_row()
	local row = wibox.layout.flex.horizontal()
	for i, v in ipairs(glyphs) do
		local icon = wibox.widget{
			align = "center",
			font = self:get_glyph_window_font(),
			text = v,
			valign = "center",
			widget = wibox.widget.textbox,
			_glyph = v,
		}

		icon:connect_signal("mouse::enter", function (icon) _.highlight_icon(self, icon) end)
		icon:connect_signal("mouse::leave", function (icon) _.restore_icon(self, icon) end)
		icon:connect_signal("button::press", function (icon, lx, ly, button) 
			-- only care about left-clicks
			if button ~= 1 then
				return
			end
			_.new_glyph_tag(self, icon) 
		end)
		row:add(icon)

		if i % glyphs_per_row == 0 then
			-- we're on our last icon for the row, add the horizontal layout
			-- to our main layout and then create a new one
			glyph_window.widgets.rows:add(row)
			row = wibox.layout.flex.horizontal()
		end
	end

	-- see if we need to add some spacer textboxes so that the last row
	-- is spaced evently with the others (in terms of columns)
	for i = 1, (glyphs_per_row - #row.children) do
		icon = wibox.widget{
			text = glyphs[1],
			visible = false,
			widget = wibox.widget.textbox
		}
		row:add(icon)
	end

	glyph_window.widgets.rows:add(row)

	glyph_window:connect_signal("mouse::leave", function ()
		glyph_window.visible = false
		if not self:get_cache_glyph_window() then
			self._private.glyph_window = nil
		end
	end)
	glyph_window:buttons(awful.util.table.join(
		-- right-click
		awful.button({ }, 3, function ()
			glyph_window.visible = false
			if not self:get_cache_glyph_window() then
				self._private.glyph_window = nil
			end
		end)
	))

	if self:get_cache_glyph_window() then
		self._private.glyph_window = glyph_window
	end

	glyph_window.visible = true
	glyph_window.screen = awful.screen.focused()
	local p = (awful.placement.scale + awful.placement.centered)
	p(glyph_window, { to_percent = 0.5 })
end

function DynamicTag:new_text_tag ()
	awful.prompt.run{
		prompt = "New tag: ",
		textbox = self.widgets.promptbox,
		exe_callback = function (tag_name) _.new_text_tag(self, tag_name) end,
		history_path = awful.util.get_cache_dir() .. "/history_dynamic_tag"
	}
end

-- {{{ Private-ish stuff
_ = (function ()
	return {
		highlight_icon = function (self, icon)
			local color = self:get_glyph_window_highlight_color()
			icon:set_markup(markup{ text = icon._glyph, color = color })
		end,

		new_glyph_tag = function (self, glyph)
			local props = self:get_tag_props()
			local s = awful.screen.focused()

			if s == nil then
				brazenutils.notify_normal("nil screen", "DynamicTag:new_glyph_tag()")
			end

			props.screen = s
			if self:get_tag_position() == "end" then
				props.index = #awful.screen.focused().tags + 1
			else
				props.index = -1
			end

			local tag = awful.tag.add(glyph._glyph, props)
			tag._is_dynamic_tag = true
			if self:get_tag_switch_to() then
				tag:view_only()
			end
		end,

		new_text_tag = function (self, tag_name)
			if tag_name == nil or #tag_name < 1 then return end

			if tag_name == "glyph" or tag_name == "icon" then
				-- TODO:
			end

			local props = self:get_tag_props() or {}
			local s = awful.screen.focused()

			if s == nil then
				brazenutils.notify_error("DynamicTag", "nil screen")
			end

			props.screen = s
			if self:get_tag_position() == "end" then
				props.index = #awful.screen.focused().tags + 1
			else
				props.index = -1
			end

			local tag = awful.tag.add(tag_name, props)
			tag._is_dynamic_tag = true
			if self:get_tag_switch_to() then
				tag:view_only()
			end
		end,

		restore_icon = function (self, icon)
			icon:set_text(icon._glyph)
			icon:set_markup(nil)
		end,
	}
end)()
-- }}}

return setmetatable(DynamicTag, {
	__call = function (cls, ...)
		return cls.new(...)
	end
})
