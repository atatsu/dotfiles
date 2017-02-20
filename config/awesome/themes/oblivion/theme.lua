local awful = require("awful")
local gears = require("gears")
local xresources = require("beautiful.xresources")

local widgetutils = require("utils.widget")
local iconutils = require("utils.icon")

local theme = dofile("/usr/share/awesome/themes/xresources/theme.lua")
local theme_assets = dofile(awful.util.getdir("config") .. "utils/assets.lua")

local theme_dir = awful.util.getdir("config") .. "themes/oblivion"

local dpi = xresources.apply_dpi
local xrdb = xresources.get_current_theme()

--[[
local colors = {
	foreground = "#f8f8f8",
	background = "#171717",
	-- black
	color0 = "#171717",
	color8 = "#38252c",
	-- red
	color1 = "#d81765",
	color9 = "#ff0000",
	-- green
	color2 = "#97d01a",
	color10 = "#76b639",
	-- yellow
	color3 = "#ffa800",
	color11 = "#e1a126",
	-- blue
	color4 = "#16b1fb",
	color12 = "#289cd5",
	-- magenta
	color5 = "#ff2491",
	color13 = "#ff2491",
	-- cyan
	color6 = "#0fdcb6",
	color14 = "#0a9b81",
	-- white
	color7 = "#ebebeb",
	color15 = "#f8f8f8",
}
--]]

-- {{{ Styles
theme.font = "glisp 8"

-- {{{ Colors
theme.fg_normal = xrdb.foreground
theme.fg_focus = xrdb.color8
theme.fg_urgent = xrdb.color1
theme.bg_normal = xrdb.background
--theme.bg_focus = xrdb.color3
--theme.bg_urgent = xrdb.color8
theme.bg_urgent = xrdb.background
theme.bg_systray = theme.bg_normal
-- }}}

-- {{{ Borders
theme.useless_gap   = dpi(3)
theme.border_width  = dpi(1)
theme.border_normal = xrdb.background
theme.border_focus  = xrdb.color12
theme.border_marked = xrdb.color9
-- }}}


-- {{{ Tooltip
-- tooltip_[border_color|bg|fg|font|border_width|opacity|shape|align]
theme.tooltip_bg = xrdb.background
theme.tooltip_border_color = xrdb.color8
-- }}}

-- {{{ Taglist
-- taglist
--	_[font|disable_icon]
-- taglist_fg_[focus|urgent|occupied|empty]
-- taglist_bg_[focus|urgent|occupied|empty]
-- taglist_squares
-- taglist_squares_[sel|unsel|sel_empty|resize]
-- taglist_shape
-- taglist_shape_[empty|focus|urgent]
-- taglist_shape_border_[color|width_empty|color_empty|width_focus|color_focus|width|urgent|color_urgent]
theme.taglist_fg_focus = xrdb.color0
theme.taglist_bg_focus = xrdb.color3
theme.taglist_shape_focus = gears.shape.circle
--theme.taglist_shape_focus = theme_assets.taglist_shape(17, 20)
-- }}}

-- {{{ Titlebar
-- titlebar
--	_bgimage
--		_[normal|focus]
--	_fg
--		_[normal|focus]
--	_bg
--		_[normal|focus]
--	_[floating|maximized|minimize|close|ontop|sticky]_button_
--		[normal|focus|normal_active|focus_active|normal_inactive|focus_inactive]
theme.titlebar_height = dpi(15)
theme.titlebar_fg_focus = xrdb.color0
theme.titlebar_bg_focus  = xrdb.color12
theme.titlebar_bg_normal = xrdb.background

local hi = (function ()
	local activeopts = { width = theme.titlebar_height, height = theme.titlebar_height }
	local inactiveopts = { width = theme.titlebar_height, theme.titlebar_height, opacity = 0.5 } 

	theme.titlebar_close_button_focus = widgetutils.color_text_surface(iconutils.close, xrdb.color0, activeopts)
	theme.titlebar_close_button_normal = widgetutils.color_text_surface(iconutils.close, xrdb.color7, activeopts)

	local buttons = { "ontop", "sticky", "floating", "maximized" }
	local states = { "focus_inactive", "focus_active", "normal_inactive", "normal_active" }

	local create_icon = widgetutils.color_text_surface
	local iconfuncs = { 
		focus_inactive = function (button) return create_icon(iconutils[button], xrdb.color0, inactiveopts) end,
		focus_active = function (button) return create_icon(iconutils[button], xrdb.color0, activeopts) end,
		normal_inactive = function (button) return create_icon(iconutils[button], xrdb.color7, inactiveopts) end,
		normal_active = function (button) return create_icon(iconutils[button], xrdb.color7, activeopts) end,
	}

	for _, button in ipairs(buttons) do
		for _, state in ipairs(states) do
			local setting = "titlebar_" .. button .. "_button_" .. state
			print(setting)
			theme[setting] = iconfuncs[state](button)
		end
	end
end)()

--[[
theme.titlebar_minimize_button_normal = "/usr/share/awesome/themes/default/titlebar/minimize_normal.png"
theme.titlebar_minimize_button_focus  = "/usr/share/awesome/themes/default/titlebar/minimize_focus.png"
--]]
-- }}}

-- {{{ Menu
-- Variables set for theming the menu:
-- menu_[bg|fg]_[normal|focus]
-- menu_[border_color|border_width]
theme.menu_height = dpi(15)
theme.menu_width  = dpi(100)
-- }}}

-- {{{ Widgets
theme.widget_icon_color = xrdb.color3
-- }}}

local background_color = theme_assets.lighten_up(theme.bg_normal, 5)
theme.wallpaper = function (s)
	return theme_assets.share.wallpaper(background_color, xrdb.color8, xrdb.color7)
end

return theme