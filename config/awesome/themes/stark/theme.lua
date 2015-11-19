------------------------------------
--      "Stark" awesome theme     --
--  By Nathan Lundquist (atatsu)  --
--      License: GNU GPL v2       --
------------------------------------

local awful = require("awful")

local colors = {
	white = "#f0f1ec", -- milk
	green = "#afd700",
	blue = "#8585ac",
	orange = "#e08829",
	--orange = "#bc7032",
	lightgrey = "#949494",
	midgrey = "#3e3e3e",
	darkgrey = "#1c1c1c",
	pink = "#d509b5",
	unknown = "#f4ff00"
}

local theme = {}
theme.confdir = awful.util.getdir("config") .. "/themes/stark/"

theme.font = "glisp 8"
--theme.font = "terminus 8"

theme.bg_normal = colors.darkgrey
--theme.bg_focus = colors.midgrey
theme.bg_focus = colors.darkgrey
theme.bg_urgent = colors.darkgrey
theme.bg_minimize = colors.darkgrey
theme.bg_systray = theme.bg_normal

theme.fg_normal = colors.lightgrey
theme.fg_focus = colors.white
theme.fg_urent = colors.orange
theme.fg_minimize = colors.pink

theme.border_width = 1
theme.border_normal = colors.midgrey
theme.border_focus = colors.lightgrey
theme.border_marked = colors.unknown

-- There are other variable sets
-- overriding the default one when 
-- defined, the sets are:
-- taglist_[bg|fg]_[focus|urgent|occupied|empty]
-- tasklist_[bg|fg]_[focus|urgent]
-- titlebar_[bg|fg]_[normal|focus]
-- tooltip_[font|opacity|fg_color|bg_color|border_width|border_color]
-- mouse_finder_[color|timeout|animate_timeout|radius|factor]
-- Example:
--theme.taglist_bg_focus = "#ff0000"

-- Display the taglist squares
theme.taglist_squares_sel = theme.confdir .. "taglist/barfp.png"
theme.taglist_squares_unsel = theme.confdir .. "taglist/barp.png"

-- Variables set for theming the menu:
-- menu_[bg|fg]_[normal|focus]
-- menu_[border_color|border_width]
--theme.menu_submenu_icon = nil
theme.menu_height = 12
--theme.menu_width	= 100

-- {{{ Titlebar icons
theme.titlebar_close_button_focus = theme.confdir .. "titlebar/close_focus.png"
theme.titlebar_close_button_normal = theme.confdir .. "titlebar/close_normal.png"

theme.titlebar_ontop_button_focus_active = theme.confdir .. "titlebar/ontop_focus_active.png"
theme.titlebar_ontop_button_normal_active = theme.confdir .. "titlebar/ontop_normal_active.png"
theme.titlebar_ontop_button_focus_inactive = theme.confdir .. "titlebar/ontop_focus_inactive.png"
theme.titlebar_ontop_button_normal_inactive = theme.confdir .. "titlebar/ontop_normal_inactive.png"

theme.titlebar_sticky_button_focus_active = theme.confdir .. "titlebar/sticky_focus_active.png"
theme.titlebar_sticky_button_normal_active = theme.confdir .. "titlebar/sticky_normal_active.png"
theme.titlebar_sticky_button_focus_inactive = theme.confdir .. "titlebar/sticky_focus_inactive.png"
theme.titlebar_sticky_button_normal_inactive = theme.confdir .. "titlebar/sticky_normal_inactive.png"

theme.titlebar_floating_button_focus_active = theme.confdir .. "titlebar/floating_focus_active.png"
theme.titlebar_floating_button_normal_active = theme.confdir .. "titlebar/floating_normal_active.png"
theme.titlebar_floating_button_focus_inactive = theme.confdir .. "titlebar/floating_focus_inactive.png"
theme.titlebar_floating_button_normal_inactive = theme.confdir .. "titlebar/floating_normal_inactive.png"

theme.titlebar_maximized_button_focus_active = theme.confdir .. "titlebar/maximized_focus_active.png"
theme.titlebar_maximized_button_normal_active = theme.confdir .. "titlebar/maximized_normal_active.png"
theme.titlebar_maximized_button_focus_inactive = theme.confdir .. "titlebar/maximized_focus_inactive.png"
theme.titlebar_maximized_button_normal_inactive = theme.confdir .. "titlebar/maximized_normal_inactive.png"
-- }}}

theme.wallpaper = theme.confdir .. "wallpaper.png"

-- {{{ Layout icons
theme.layout_fairh = theme.confdir .. "layouts/fairh.png"
theme.layout_fairv = theme.confdir .. "layouts/fairv.png"
theme.layout_floating = theme.confdir .. "layouts/floating.png"
theme.layout_magnifier = theme.confdir .. "layouts/magnifier.png"
theme.layout_max = theme.confdir .. "layouts/max.png"
theme.layout_fullscreen = theme.confdir .. "layouts/fullscreen.png"
theme.layout_tilebottom = theme.confdir .. "layouts/tilebottom.png"
theme.layout_tileleft = theme.confdir .. "layouts/tileleft.png"
theme.layout_tile = theme.confdir .. "layouts/tile.png"
theme.layout_tiletop = theme.confdir .. "layouts/tiletop.png"
theme.layout_spiral = theme.confdir .. "layouts/spiral.png"
theme.layout_dwindle = theme.confdir .. "layouts/dwindle.png"
-- }}}

-- {{{ Widget icons
theme.widget_cpu = theme.confdir .. "widgets/cpu.png"
theme.widget_mem = theme.confdir .. "widgets/mem.png"
theme.widget_clock = theme.confdir .. "widgets/clock.png"
theme.widget_mail = theme.confdir .. "widgets/mail.png"
theme.widget_pacman = theme.confdir .. "widgets/pacman.png"
theme.widget_volume = theme.confdir .. "widgets/vol.png"
theme.widget_mpd = theme.confdir .. "widgets/music.png"
theme.widget_disk = theme.confdir .. "widgets/disk.png"
theme.widget_disk_2 = theme.confdir .. "widgets/disk_2.png"
theme.widget_disk_3 = theme.confdir .. "widgets/disk_3.png"
theme.widget_disk_4 = theme.confdir .. "widgets/disk_4.png"
theme.widget_disk_5 = theme.confdir .. "widgets/disk_5.png"
theme.widget_disk_6 = theme.confdir .. "widgets/disk_6.png"
theme.widget_disk_7 = theme.confdir .. "widgets/disk_7.png"
-- }}}
theme.awesome_icon = theme.confdir .. "awesome.png"

-- Define the icon theme for application icons. If not set then the icons
-- from /usr/share/icons and /usr/share/icons/hicolor will be used.
theme.icon_theme = nil

-- {{{ Giblets
theme.giblets = {}
theme.giblets.widgets = {}

-- disk usage
theme.giblets.diskusage = {}
theme.giblets.diskusage.window_border_width = 0

-- progressbar
theme.giblets.widgets.progressbar = {
	width = 100,
	height = 10,
	ticks_align = "bottom",
	border_color = colors.lightgrey,
	background_color = colors.darkgrey,
	foreground_color = colors.lightgrey,
}
-- }}}

theme.colors = colors

return theme
