------------------------------------
--    "BusyBee" awesome theme     --
--  By Nathan Lundquist (Atatsu)  --
--       License: GNU GPL v2      -- 
------------------------------------

-- {{{ Main
theme = {}
theme.confdir = awful.util.getdir("config")
theme.wallpaper_cmd = { "/usr/bin/nitrogen --restore" }

-- {{{ Styles
theme.font      = "glisp 8"

-- {{{ Colors
white		= "#FFFFFF"
green		= "#AFD700"
blue		= "#8585AC"
orange		= "#C96E07"
lightgrey	= "#949494"
midgrey		= "#3E3E3E"
darkgrey	= "#1C1C1C"

theme.fg_normal = white
theme.fg_focus  = green
theme.fg_urgent = orange
theme.bg_normal = darkgrey
theme.bg_focus  = midgrey
theme.bg_urgent = darkgrey

theme.fg_end_widget = orange
theme.fg_center_widget = blue
theme.fg_widget = green
-- }}}

-- {{{ Borders
theme.border_width  = "1"
theme.border_normal = darkgrey
theme.border_focus  = blue
theme.border_marked = blue
-- }}}
-- }}}

-- {{{ Menu
--theme.menu_submenu_icon = theme.confdir .. "/icons/awesome_o.png"
--theme.menu_height       = "15"
--theme.menu_width	= "100"
-- }}}

-- {{{ Misc icons
theme.awesome_icon      = theme.confdir .. "/icons/awesome_oblivion.png"
-- }}}
-- {{{ Layout icons
theme.layout_tile       = theme.confdir .. "/icons/layouts/tile.png"
theme.layout_tileleft   = theme.confdir .. "/icons/layouts/tileleft.png"
theme.layout_tilebottom = theme.confdir .. "/icons/layouts/tilebottom.png"
theme.layout_tiletop    = theme.confdir .. "/icons/layouts/tiletop.png"
theme.layout_fairv      = theme.confdir .. "/icons/layouts/fairv.png"
theme.layout_fairh      = theme.confdir .. "/icons/layouts/fairh.png"
theme.layout_spiral     = theme.confdir .. "/icons/layouts/spiral.png"
theme.layout_dwindle    = theme.confdir .. "/icons/layouts/dwindle.png"
theme.layout_max        = theme.confdir .. "/icons/layouts/max.png"
theme.layout_fullscreen = theme.confdir .. "/icons/layouts/fullscreen.png"
theme.layout_magnifier  = theme.confdir .. "/icons/layouts/magnifier.png"
theme.layout_floating   = theme.confdir .. "/icons/layouts/floating.png"
-- }}}

-- {{{ Titlebar
theme.titlebar_close_button_focus = theme.confdir .. "/icons/titlebar/close_focus.png"
theme.titlebar_close_button_normal = theme.confdir .. "/icons/titlebar/close_normal.png"

theme.titlebar_ontop_button_focus_active    = theme.confdir .. "/icons/titlebar/ontop_focus_active.png"
theme.titlebar_ontop_button_normal_active   = theme.confdir .. "/icons/titlebar/ontop_normal_active.png"
theme.titlebar_ontop_button_focus_inactive  = theme.confdir .. "/icons/titlebar/ontop_focus_inactive.png"
theme.titlebar_ontop_button_normal_inactive = theme.confdir .. "/icons/titlebar/ontop_normal_inactive.png"

theme.titlebar_sticky_button_focus_active    = theme.confdir .. "/icons/titlebar/sticky_focus_active.png"
theme.titlebar_sticky_button_normal_active   = theme.confdir .. "/icons/titlebar/sticky_normal_active.png"
theme.titlebar_sticky_button_focus_inactive  = theme.confdir .. "/icons/titlebar/sticky_focus_inactive.png"
theme.titlebar_sticky_button_normal_inactive = theme.confdir .. "/icons/titlebar/sticky_normal_inactive.png"

theme.titlebar_floating_button_focus_active    = theme.confdir .. "/icons/titlebar/floating_focus_active.png"
theme.titlebar_floating_button_normal_active   = theme.confdir .. "/icons/titlebar/floating_normal_active.png"
theme.titlebar_floating_button_focus_inactive  = theme.confdir .. "/icons/titlebar/floating_focus_inactive.png"
theme.titlebar_floating_button_normal_inactive = theme.confdir .. "/icons/titlebar/floating_normal_inactive.png"

theme.titlebar_maximized_button_focus_active    = theme.confdir .. "/icons/titlebar/maximized_focus_active.png"
theme.titlebar_maximized_button_normal_active   = theme.confdir .. "/icons/titlebar/maximized_normal_active.png"
theme.titlebar_maximized_button_focus_inactive  = theme.confdir .. "/icons/titlebar/maximized_focus_inactive.png"
theme.titlebar_maximized_button_normal_inactive = theme.confdir .. "/icons/titlebar/maximized_normal_inactive.png"
-- }}}

-- {{{ Widget icons
theme.widget_cpu    = theme.confdir .. "/icons/cpu_oblivion.png"
theme.widget_mem    = theme.confdir .. "/icons/mem_oblivion.png"
theme.widget_clock  = theme.confdir .. "/icons/time_oblivion.png"
theme.widget_mail   = theme.confdir .. "/icons/mail_oblivion.png"
theme.widget_mpd    = theme.confdir .. "/icons/music_oblivion.png"
theme.widget_pacman = theme.confdir .. "/icons/pacman_oblivion.png"
theme.widget_volume = theme.confdir .. "/icons/vol_oblivion.png"
-- }}}

return theme
