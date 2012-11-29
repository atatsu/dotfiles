-- {{{ License
--
-- Awesome configuration, using awesome 3.4.5-1 on Arch Linux
-- Nathan Lundquist <nathan.lundquist@gmail.com>
--
-- }}}

-- {{{ Dependencies
--
-- Packages:
-- dmenu
-- dmenu-path-c
-- rxvt-unicode-256color
-- dictd
--
-- Lua:
-- bashets
-- teardrop
--
-- }}}


-- {{{ Libraries
-- Standard awesome library
require("awful")
require("awful.autofocus")
require("awful.rules")
-- Theme handling library
require("beautiful")
-- Notification library
require("naughty")
-- Vicious widget library
vicious = require("vicious")
-- Bashets
require("bashets")
bashets.set_script_path('/home/atatsu/.config/awesome/scripts/')
-- Community 
require("teardrop")
require("utils")
-- }}}

-- {{{ Variable definitions
-- Themes define colours, icons, and wallpapers
--beautiful.init("/usr/share/awesome/themes/zenburn/theme.lua")
--beautiful.init("/usr/share/awesome/themes/sky/theme.lua")
beautiful.init(awful.util.getdir("config") .. "/oblivion.lua")

-- This is used later as the default terminal and editor to run.
terminal = "urxvt"
editor = os.getenv("EDITOR") or "nano"
editor_cmd = terminal .. " -e " .. editor

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
local modkey = "Mod4"

-- Function aliases
local exec = awful.util.spawn
local sexec = awful.util.spawn_with_shell

-- Table of layouts to cover with awful.layout.inc, order matters.
layout = {
    tile = awful.layout.suit.tile, 
    left = awful.layout.suit.tile.left,	
    bottom = awful.layout.suit.tile.bottom,
    top = awful.layout.suit.tile.top,	
    fair = awful.layout.suit.fair,
    horizontal = awful.layout.suit.fair.horizontal,
    spiral = awful.layout.suit.spiral,
    dwindle = awful.layout.suit.spiral.dwindle,
    max = awful.layout.suit.max,
    fullscreen = awful.layout.suit.max.fullscreen,
    magnifier = awful.layout.suit.magnifier,
    floating = awful.layout.suit.floating
}

layouts = {
    awful.layout.suit.tile, 
    awful.layout.suit.tile.left,	
    awful.layout.suit.tile.bottom,
    awful.layout.suit.tile.top,	
    awful.layout.suit.fair,
    awful.layout.suit.fair.horizontal,
    awful.layout.suit.spiral,
    awful.layout.suit.spiral.dwindle,
    awful.layout.suit.max,
    awful.layout.suit.max.fullscreen,
    awful.layout.suit.magnifier,
    awful.layout.suit.floating
}
-- }}}

-- {{{ Tags
-- Define a tag table which hold all screen tags.

tags = {
    {
	names  = { "remote",        "dev",       "pycharm",       "email",     "music",     "video",         "games",         "graphics"      }, -- tags[1]
	layout = { layout.floating, layout.tile, layout.floating, layout.tile, layout.tile, layout.floating, layout.floating, layout.floating }
    }, 
    {
	names  = { "web",            "chat",           "run",            "debug"          }, -- tags[2]
	layout = { layout.magnifier, layout.magnifier, layout.magnifier, layout.magnifier }
    }
}

for s = 1, screen.count() do
    -- Each screen has its own tag table.
    tags[s] = awful.tag(tags[s].names, s, tags[s].layout)
end
-- }}}

-- {{{ Menu
-- Create a laucher widget and a main menu
myawesomemenu = {
   { "manual", terminal .. " -e man awesome" },
   { "edit config", editor_cmd .. " " .. awful.util.getdir("config") .. "/rc.lua" },
   { "edit menu", editor_cmd .. " " .. awful.util.getdir("config") .. "/menu.lua" }, 
   { "restart", awesome.restart },
   { "quit", awesome.quit }
}

mymainmenu = awful.menu({ items = { 
	{ "awesome", myawesomemenu, beautiful.awesome_icon },
	{ "firefox", "firefox" }, 
	{ "terminal", terminal }, 
    }
})

mylauncher = awful.widget.launcher({ image = image(beautiful.awesome_icon),
                                     menu = mymainmenu })
-- }}}

-- {{{ Wibox
--
-- {{{ Widgets configuration
--
-- {{{ Separators
spacer = widget({ type = "textbox" })
separator = widget({ type = "textbox" })
separator.text, spacer.text = "|", " "
-- }}}

-- {{{ CPU usage and temperature
cpuicon = widget({ type = "imagebox" })
cpuicon.image = image(beautiful.widget_cpu)
-- Initialize widgets
cpugraph  = awful.widget.graph()
tzswidget = widget({ type = "textbox" })
-- Graph properties
cpugraph:set_width(40):set_height(14)
cpugraph:set_background_color(beautiful.fg_off_widget)
cpugraph:set_gradient_angle(0):set_gradient_colors({
   beautiful.fg_end_widget, beautiful.fg_center_widget, beautiful.fg_widget}) 
-- Register widgets
vicious.register(cpugraph,  vicious.widgets.cpu,      "$1")
vicious.register(tzswidget, vicious.widgets.thermal, " $1C", 19, "thermal_zone0")
-- }}}

-- {{{ Memory usage
memicon = widget({ type = "imagebox" })
memicon.image = image(beautiful.widget_mem)
-- Initialize widget
memwidget = widget({ type = "textbox" })
-- Register widget
vicious.register(memwidget, vicious.widgets.mem, "$1%", 13)
-- }}}

-- {{{ New mail
mailicon = widget({ type = "imagebox" })
mailicon.image = image(beautiful.widget_mail)
-- Initialize widget
mailwidget = widget({ type = "textbox", name = "mailwidget" })
-- Register widget
bashets.register(mailwidget, "new_mail", "$1", 181)
-- }}}

-- {{{ Pacman updates
pacicon = widget({ type = "imagebox" })
pacicon.image = image(beautiful.widget_pacman)
-- Initialize widget
pacwidget = widget({ type = "textbox", name = "pacwidget" })
-- Register widget
bashets.register(pacwidget, "pacupdates", "$1", 601)
-- }}}

-- {{{ MPD Status
mpdicon = widget({ type = "imagebox" })
mpdicon.image = image(beautiful.widget_mpd)
-- Initialize widget
mpdwidget = widget({ type = "textbox", name = "mpdwidget" })
--Register widget
bashets.register(mpdwidget, "mpd.sh", "$1 $2 $3", 3, "|")
-- }}}

-- {{{ Volume
volicon = widget({ type = "imagebox" })
volicon.image = image(beautiful.widget_volume)
--Initialize widget
volwidget = widget({ type = "textbox" })
--Register widget
vicious.register(volwidget, vicious.widgets.volume, "$1%", 2, "Master")
-- }}}

-- {{{ Clock
clockicon = widget({ type = "imagebox" })
clockicon.image = image(beautiful.widget_clock)
-- Create a textclock widget
clockwidget = awful.widget.textclock({ align = "left" })
-- }}}

-- }}}

-- Create a systray
mysystray = widget({ type = "systray" })

-- Create a wibox for each screen and add it
mywibox = {}
mypromptbox = {}
mylayoutbox = {}
mytaglist = {}
mytaglist.buttons = awful.util.table.join(
    awful.button({ }, 1, awful.tag.viewonly),            -- Left click
    awful.button({ modkey }, 1, awful.client.movetotag), -- Windows key + Left click
    awful.button({ }, 3, awful.tag.viewtoggle),		 -- Right click
    awful.button({ modkey }, 3, awful.client.toggletag), -- Windows key + Right click
    awful.button({ }, 4, awful.tag.viewnext),		 -- Scroll up
    awful.button({ }, 5, awful.tag.viewprev)		 -- Scroll down
)

for s = 1, screen.count() do
    -- Create a promptbox for each screen
    mypromptbox[s] = awful.widget.prompt({ layout = awful.widget.layout.horizontal.leftright })
    -- Create an imagebox widget which will contains an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    mylayoutbox[s] = awful.widget.layoutbox(s)
    mylayoutbox[s]:buttons(awful.util.table.join(
                           awful.button({ }, 1, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
                           awful.button({ }, 4, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end)))
    -- Create a taglist widget
    mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.label.all, mytaglist.buttons)

    -- Create the wibox
    mywibox[s] = awful.wibox({ position = "top", screen = s, height = 14 })
    -- Add widgets to the wibox - order matters
    mywibox[s].widgets = {
        {
            mylauncher,
            mytaglist[s],
	    mylayoutbox[s],
            mypromptbox[s],
            layout = awful.widget.layout.horizontal.leftright
        },
        s == 1 and mysystray or nil,
        spacer, clockwidget, spacer, clockicon, 
	spacer, pacwidget, spacer, pacicon, 
	spacer, volwidget, spacer, volicon, 
	spacer, mpdwidget, spacer, mpdicon, 
	spacer, mailwidget, spacer, mailicon, 
	spacer, memwidget, spacer, memicon, 
	spacer, tzswidget, cpugraph.widget, spacer, cpuicon, 
        layout = awful.widget.layout.horizontal.rightleft
    }
end
-- }}}

-- {{{ Mouse bindings
root.buttons(awful.util.table.join(
    awful.button({ }, 3, function () mymainmenu:toggle() end),
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}

-- {{{ Key bindings
--
-- {{{ Global keys
globalkeys = awful.util.table.join(

    -- {{{ Applications
    awful.key({ modkey, "Control" }, "o", function () exec("xlock") end), 
    --awful.key({ modkey, "Control" }, "p", function () exec("clementine --play-pause") end), 
    awful.key({ modkey, "Control" }, "p", function () exec("mpc toggle") end), 
    --awful.key({ modkey, "Shift"   }, ",", function () exec("clementine --previous") end), 
    awful.key({ modkey, "Shift"   }, ",", function () exec("mpc prev") end), 
    --awful.key({ modkey, "Shift"   }, ".", function () exec("clementine --next") end), 
    awful.key({ modkey, "Shift"   }, ".", function () exec("mpc next") end), 
    awful.key({ modkey, "Control" }, "-", function () exec("amixer set Master 5%-") end), 
    awful.key({ modkey, "Control" }, "=", function () exec("amixer set Master 5%+") end), 
    awful.key({ modkey            }, "grave", function () teardrop(terminal, "bottom", "center", 1000) end), 
    -- }}}
    
    -- {{{ Prompt Menus
    --awful.key({ modkey }, "r", function () mypromptbox[mouse.screen]:run() end),
    awful.key({ modkey }, "r", function () 
	sexec("exe=`dmenu_path_c | dmenu -b -nf '#888888' -nb '#222222' -sf '#ffffff' -sb '#285577'` && exec $exe")
    end), 
    awful.key({ modkey }, "d", function () 
	awful.prompt.run({ prompt = "Dictionary: " }, mypromptbox[mouse.screen].widget, 
	    function (words)
		sexec("dict "..words.." | ".."xmessage -file -") --dictd package
	    end)
    end), 
    -- }}}
    
    -- {{{ Tag browsing
    awful.key({ modkey,           }, "p",   awful.tag.viewprev       ),
    awful.key({ modkey,           }, "n",  awful.tag.viewnext       ),
    awful.key({ modkey,           }, "Escape", awful.tag.history.restore),
    -- }}}

    awful.key({ modkey,           }, "j",
        function ()
            awful.client.focus.byidx( 1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "k",
        function ()
            awful.client.focus.byidx(-1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "w", function () mymainmenu:show(true)        end),

    -- Layout manipulation
    awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end),
    awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end),
    awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end),
    awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end),
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto),
    awful.key({ modkey,           }, "Tab",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end),

    -- Standard program
    awful.key({ modkey,           }, "Return", function () awful.util.spawn(terminal) end),
    awful.key({ modkey, "Control" }, "r", awesome.restart),
    awful.key({ modkey, "Shift"   }, "q", awesome.quit),

    awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)    end),
    awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)    end),
    awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1)      end),
    awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1)      end),
    awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1)         end),
    awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1)         end),
    awful.key({ modkey,           }, "space", function () awful.layout.inc(layouts,  1) end),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(layouts, -1) end),


    awful.key({ modkey }, "x",
	  function ()
	      awful.prompt.run({ prompt = "Run Lua code: " },
	      mypromptbox[mouse.screen].widget,
	      awful.util.eval, nil,
	      awful.util.getdir("cache") .. "/history_eval")
	  end) 
)

-- {{{ Client manipulation
clientkeys = awful.util.table.join(
    awful.key({ modkey }, "-",  function () awful.client.moveresize(10, 10, -20, -20) end),
    awful.key({ modkey }, "=", function () awful.client.moveresize(-10, -10, 20, 20) end),
    awful.key({ modkey }, "Down",  function () awful.client.moveresize(0, 20, 0, 0) end),
    awful.key({ modkey }, "Up",    function () awful.client.moveresize(0, -20, 0, 0) end),
    awful.key({ modkey }, "Left",  function () awful.client.moveresize(-20, 0, 0, 0) end),
    awful.key({ modkey }, "Right", function () awful.client.moveresize(20, 0, 0, 0) end),
    awful.key({ modkey,           }, "f",      function (c) c.fullscreen = not c.fullscreen  end),
    awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end),
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end),
    awful.key({ modkey,           }, "o",      awful.client.movetoscreen                        ),
    awful.key({ modkey, "Shift"   }, "r",      function (c) c:redraw()                       end),
    --awful.key({ modkey,           }, "n",      function (c) c.minimized = not c.minimized    end),
    awful.key({modkey, }, "t", function (c)
	if c.titlebar then awful.titlebar.remove(c)
	else awful.titlebar.add(c, { modkey = modkey }) end
    end), 
    awful.key({ modkey,           }, "m",
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c.maximized_vertical   = not c.maximized_vertical
        end)
)
-- }}}

-- Compute the maximum number of digit we need, limited to 9
keynumber = 0
for s = 1, screen.count() do
   keynumber = math.min(9, math.max(#tags[s], keynumber));
end

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, keynumber do
    globalkeys = awful.util.table.join(globalkeys,
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local screen = mouse.screen
                        if tags[screen][i] then
                            awful.tag.viewonly(tags[screen][i])
                        end
                  end),
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                      local screen = mouse.screen
                      if tags[screen][i] then
                          awful.tag.viewtoggle(tags[screen][i])
                      end
                  end),
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus and tags[client.focus.screen][i] then
                          awful.client.movetotag(tags[client.focus.screen][i])
                      end
                  end),
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus and tags[client.focus.screen][i] then
                          awful.client.toggletag(tags[client.focus.screen][i])
                      end
                  end))
end

clientbuttons = awful.util.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize))

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
awful.rules.rules = {
    { rule = { }, properties = { 
	border_width = beautiful.border_width,
	border_color = beautiful.border_normal,
	focus = true,
	keys = clientkeys,
	buttons = clientbuttons } 
    },
    {
	rule = {
	    class = "Luakit"
	}, 
	properties = {
	    floating = true
	}
    }, 
    {
	rule = {
	    title = "Music"
	},
	properties = {
	    tag = tags[1][5], 
	    switchtotag = true
	}
    },
    {
	rule = {
	    class = "Mumble", 
	    instance = "mumble"
	}, 
	properties = {
	    floating = true, 
	}
    }, 
    { 
	rule = { 
	    class = "XCalc"
	}, 
	properties = { 
	    floating = true 
	} 
    },  
    {
	rule = {
	    name = "Clementine", 
	}, 
	properties = {
	    tag = utils.get_tag_by_name("music", tags), 
	    switchtotag = true
	}
    }, 
    {
	rule = {
	    class = "urxvt", 
	}, 
	callback = awful.titlebar.remove
    }, 
    { 
	rule = { 
	    class = "gimp" 
	},
	properties = { 
	    floating = true 
	} 
    },
    { 
	rule = { 
	    class = "feh" 
	}, 
	properties = { 
	    floating = true 
	} 
    }, 
    { 
	rule = { 
	    class = "Xmessage", 
	    instance = "xmessage" 
	}, 
	properties = { 
	    floating = true 
	} 
    }
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.add_signal("manage", function (c, startup)
    -- Add a titlebar if floating
    if awful.client.floating.get(c) or awful.layout.get(c.screen) == awful.layout.suit.floating then
	if c.titlebar then
	    awful.titlebar.remove(c)
	else
	    awful.titlebar.add(c, {modkey = modkey })
	end
    end

    -- Enable sloppy focus
    c:add_signal("mouse::enter", function(c)
        if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
            and awful.client.focus.filter(c) then
            client.focus = c
        end
    end)

    if not startup then
        -- Set the windows at the slave,
        -- i.e. put it at the end of others instead of setting it master.
        -- awful.client.setslave(c)

        -- Put windows in a smart way, only if they does not set an initial position.
        if not c.size_hints.user_position and not c.size_hints.program_position then
            awful.placement.no_overlap(c)
            awful.placement.no_offscreen(c)
        end
    end
end)

client.add_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.add_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}

-- {{{ Tasklist bar for each screen
tasklistbar = {}
tasklist = {}
tasklist.buttons = awful.util.table.join(
    awful.button({ }, 1, function(c)
	if not c:isvisible() then
	    awful.tag.viewonly(c:tags()[1])
	end
	client.focus = c
	c:raise()
    end), 
    awful.button({ }, 3, function(c)
	if instance then
	    instance:hide()
	    instance = nil
	else
	    instance = awful.menu.clients({ width = 250 })
	end
    end)
)
for s = 1, screen.count() do
    -- Create tasklist widget
    tasklist[s] = awful.widget.tasklist(function(c)
	return awful.widget.tasklist.label.currenttags(c, s)
    end, tasklist.buttons)
    -- Create the tasklistbar(wibox)
    tasklistbar[s] = awful.wibox({ screen = s, height = 14, position = "bottom" })
    tasklistbar[s].widgets = {
	tasklist[s], 
	layout = awful.widget.layout.horizontal.rightleft
    }
end
-- }}}

-- Start Bashets
bashets.start()

