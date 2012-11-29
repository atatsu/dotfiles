------------------------------------
--    "BusyBee" awesome theme     --
--  By Nathan Lundquist (Atatsu)  --
--       License: GNU GPL v2      -- 
------------------------------------

-- {{{ Main
theme = {}
theme.confdir = awful.util.getdir("config")

-- {{{ Styles
theme.font      = "glisp 8"

-- {{{ Colors
white		= "#FFFFFF"
green		= "#AFD700"
blue		= "#8585AC"
orange		= "#C96E07"
lightgrey	= "#949494"
midgrey		= "#262626"
darkgrey	= "#1C1C1C"

theme.fg_normal = white
theme.fg_focus  = green
theme.fg_urgent = "#C96E07"
theme.bg_normal = darkgrey
theme.bg_focus  = midgrey
theme.bg_urgent = darkgrey
-- }}}

-- {{{ Borders
theme.border_width  = "1"
theme.border_normal = midgrey
theme.border_focus  = orange
theme.border_marked = "#C96E07"
-- }}}
-- }}}

-- {{{ Menu
--theme.menu_submenu_icon = theme.confdir .. "/icons/awesome_o.png"
--theme.menu_height       = "15"
--theme.menu_width	= "100"
-- }}}

-- {{{ Misc icons
theme.awesome_icon      = theme.confdir .. "/icons/awesome_bee.png"
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

-- {{{ Widget icons
theme.widget_mem    = theme.confdir .. "/icons/mem_bee.png"
theme.widget_clock  = theme.confdir .. "/icons/time_bee.png"
-- }}}

return theme
