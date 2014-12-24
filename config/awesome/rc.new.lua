-- Awesome configuration, using awesome 3.5.5-1 on Arch Linux
-- Nathan Lundquist <nathan.lundquist@gmail.com>

-- {{{ Dependencies
-- Packages:
--   dmenu
--   dmenu-path-c
--   rxvt-unicode-256color
--   dictd
-- }}}

-- {{{ Libaries
-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
awful.rules = require("awful.rules")
require("awful.autofocus")
-- Widget and layout library
local wibox = require("wibox")
-- Theme handling library
local beautiful = require("beautiful")
-- Notification library
local naughty = require("naughty")
local menubar = require("menubar")
-- }}}

local utils = {}

-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
  naughty.notify({ 
    preset = naughty.config.presets.critical,
    title = "Oops, there were errors during startup!",
    text = awesome.startup_errors 
  })
end

-- Handle runtime errors after startup
do
  local in_error = false
  awesome.connect_signal("debug::error", function (err)
    -- Make sure we don't go into an endless error loop
    if in_error then return end
    in_error = true

    naughty.notify({ 
      preset = naughty.config.presets.critical,
      title = "Oops, an error happened!",
      text = err 
    })
    in_error = false
  end)
end
-- }}}

-- {{{ Variable definitions
-- Themes define colours, icons, font and wallpapers.
beautiful.init(awful.util.getdir("config") .. "/themes/busybee/theme.lua")
--beautiful.init("/usr/share/awesome/themes/default/theme.lua")

-- This is used later as the default terminal and editor to run.
terminal = "urxvt"
editor = os.getenv("EDITOR") or "nano"
editor_cmd = terminal .. " -e " .. editor

-- Valid modifiers: Any, Mod1, Mod2, Mod3, Mod4, Mod5, Shift, Lock, Control

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"

-- Function aliases
local exec = awful.util.spawn
local sexec = awful.util.spawn_with_shell
local pread = awful.util.pread

-- Table of layouts to cover with awful.layout.inc, order matters.
local layout = {
  floating = awful.layout.suit.floating,
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
  magnifier = awful.layout.suit.magnifier
}
local layouts = {
  awful.layout.suit.floating,
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
  awful.layout.suit.magnifier
}
-- }}}

-- {{{ Wallpaper
if beautiful.wallpaper then
  for s = 1, screen.count() do
    gears.wallpaper.maximized(beautiful.wallpaper, s, true)
  end
end
-- }}}

-- {{{ Tags
-- Define a tag table which hold all screen tags.
local tags = {
  {
    names = {
      "web",
      "dev",
      "gfx",
      "steam",
      "games",
      "misc",
    },
    layout = {
      layout.magnifier,
      layout.tile,
      layout.floating,
      layout.tile,
      layout.fullscreen,
      layout.tile,
    }
  },
  {
    names = {
      "chat",
      "vids",
      "misc",
    },
    layout = {
      layout.tile,
      layout.max,
      layout.tile,
    }
  }
}

for s = 1, screen.count() do
  if tags[s] then
    tags[s] = awful.tag(tags[s].names, s, tags[s].layout)
  else
    -- if additional monitors get hooked up and haven't been accounted
    -- for, just use the stock tag setup on them
    tags[s] = awful.tag({1, 2, 3, 4, 5, 6, 7, 8, 9}, s, layout.tile)
  end
end

-- Connect a signal to every tag so we know when the layout has changed. If the 
-- layout changes to a floating layout, the clients need their titlebars shown. 
-- If the layout changes to a non-floating layout, the clients need their
-- titlebars hidden.
for s = 1, screen.count() do
  local screen_tags = awful.tag.gettags(s)
  for _, tag in ipairs(screen_tags) do
    tag:connect_signal("property::layout", function(t)
      local clients = t:clients()

      for _, c in ipairs(clients) do
        if c.type ~= "normal" or awful.client.floating.get(c) then
          -- ignore clients that aren't "normal"
          -- ignore clients that are already floating
          return
        end

        if awful.layout.get(c.screen) == layout.floating then
          awful.titlebar.show(c)
        else
          awful.titlebar.hide(c)
        end
      end
    end)
  end
end
-- }}}

-- {{{ Menu
-- Create a laucher widget and a main menu
local awesome_menu = {
  {"manual", terminal .. " -e man awesome"},
  {"edit config", editor_cmd .. " " .. awesome.conffile},
  {"restart", awesome.restart},
  {"quit", awesome.quit}
}

local main_menu = awful.menu({
  items = {
    {"awesome", awesome_menu, beautiful.awesome_icon},
    {"terminal", terminal}
  }
})

local launcher = awful.widget.launcher({
  image = beautiful.awesome_icon,
  menu = main_menu
})

-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
-- }}}

-- {{{ Wibox
-- Create a textclock widget
local clock = awful.widget.textclock()

-- Create a wibox for each screen and add it
local main_wibox = {}
local main_promptbox = {}
local main_layoutbox = {}

-- table of buttons for our taglist
local taglist = {}
taglist.buttons = awful.util.table.join(
  -- left-click, view the selected tag only
  awful.button({ }, 1, awful.tag.viewonly),
  -- mod + left-click, move the focused client to the selected tag
  awful.button({ modkey }, 1, awful.client.movetotag),
  -- right-click, toggle selection of the selected tag
  awful.button({ }, 3, awful.tag.viewtoggle),
  -- mod + right-click, toggle the tag the focused client is on
  awful.button({ modkey }, 3, awful.client.toggletag),
  -- scroll up, view next tag
  awful.button({ }, 4, function(t) awful.tag.viewnext(awful.tag.getscreen(t)) end),
  -- scroll down, view previous tag
  awful.button({ }, 5, function(t) awful.tag.viewprev(awful.tag.getscreen(t)) end)
)

-- table of buttons for our tasklist
local main_tasklist = {}
local _clients_popup
main_tasklist.buttons = awful.util.table.join(
  -- left-click, if client is not minimized, minimize it, if client
  -- is minimized, unminimize it
  awful.button({ }, 1, function (c)
    if c == client.focus then
      c.minimized = true
    else
      -- Without this, the following
      -- :isvisible() makes no sense
      c.minimized = false

      if not c:isvisible() then
        awful.tag.viewonly(c:tags()[1])
      end

      -- This will also un-minimize
      -- the client, if needed
      client.focus = c
      c:raise()
    end
  end),
  -- right-click, show a pop-up menu of clients on this tag, if the pop-up is
  -- already visible, close it
  awful.button({ }, 3, function ()
    if _clients_popup then
      _clients_popup:hide()
      _clients_popup = nil
    else
      _clients_popup = awful.menu.clients({
        theme = { width = 250 }
      })
    end
  end),
  -- scroll up, 
  awful.button({ }, 4, function ()
    awful.client.focus.byidx(1)
    if client.focus then client.focus:raise() end
  end),
  -- scroll down, 
  awful.button({ }, 5, function ()
    awful.client.focus.byidx(-1)
    if client.focus then client.focus:raise() end
  end)
)

-- now actually add the wibox, layoutbox, taglist, tasklist, and promptbox to each screen
for s = 1, screen.count() do
  -- Create a promptbox for each screen
  main_promptbox[s] = awful.widget.prompt()

  -- Create an imagebox widget which will contains an icon indicating which layout we're using.
  -- We need one layoutbox per screen.
  main_layoutbox[s] = awful.widget.layoutbox(s)
  main_layoutbox[s]:buttons(awful.util.table.join(
    -- left-click, go to next layout
    awful.button({ }, 1, function () awful.layout.inc(layouts, 1) end),
    -- right-click, go to previous layout
    awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
    -- scroll up, go to next layout
    awful.button({ }, 4, function () awful.layout.inc(layouts, 1) end),
    -- scroll down, go to previous layout
    awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end)
  ))

  -- Create a taglist widget
  taglist[s] = awful.widget.taglist(s, awful.widget.taglist.filter.all, taglist.buttons)

  -- Create a tasklist widget
  main_tasklist[s] = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, main_tasklist.buttons)

  -- Create the wibox
  main_wibox[s] = awful.wibox({ position = "top", screen = s })

  -- Widgets that are aligned to the left
  local left_layout = wibox.layout.fixed.horizontal()
  left_layout:add(launcher)
  left_layout:add(taglist[s])
  left_layout:add(main_promptbox[s])

  -- Widgets that are aligned to the right
  local right_layout = wibox.layout.fixed.horizontal()
  -- add a systray to the first screen
  if s == 1 then right_layout:add(wibox.widget.systray()) end
  right_layout:add(clock)
  right_layout:add(main_layoutbox[s])

  -- Now bring it all together (with the tasklist in the middle)
  local layout = wibox.layout.align.horizontal()
  layout:set_left(left_layout)
  layout:set_middle(main_tasklist[s])
  layout:set_right(right_layout)

  main_wibox[s]:set_widget(layout)
end
-- }}}

-- {{{ Mouse bindings for the root window (when no clients are covering it up)
root.buttons(awful.util.table.join(
  -- right-click, toggle the main menu
  awful.button({ }, 3, function () main_menu:toggle() end),
  -- scroll up, view next tag
  awful.button({ }, 4, awful.tag.viewnext),
  -- scroll down, view previous tag
  awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}

-- {{{ Key bindings
local globalkeys = awful.util.table.join(
  --
  -- mod + left, go to previous tag
  awful.key({ modkey, }, "p", awful.tag.viewprev),
  --
  -- mod + right, go to next tag
  awful.key({ modkey, }, "n", awful.tag.viewnext),
  --
  -- mod + escape, go to last viewed tag
  awful.key({ modkey, }, "Escape", awful.tag.history.restore),
  --
  -- mod + j, switch focus to the next client, also raises client so that it is on top
  awful.key({ modkey, }, "j", function()
    awful.client.focus.byidx(1)
    if client.focus then client.focus:raise() end
  end),
  --
  -- mod + k, switch focus to the prev client, also raises client so that it is on top
  awful.key({ modkey, }, "k", function()
    awful.client.focus.byidx(-1)
    if client.focus then client.focus:raise() end
  end),
  --
  -- mod + w, show the main menu
  awful.key({ modkey, }, "w", function() main_menu:show() end),

  -- Layout manipulation
  --
  -- mod + shift + j, swap client forward
  awful.key({ modkey, "Shift" }, "j", function() awful.client.swap.byidx(1) end),
  --
  -- mod + shift + k, swap client backward
  awful.key({ modkey, "Shift"   }, "k", function() awful.client.swap.byidx(-1) end),
  --
  -- mod + control + j, focus next screen
  awful.key({ modkey, "Control" }, "j", function() awful.screen.focus_relative(1) end),
  --
  -- mod + control + k, focus prev screen
  awful.key({ modkey, "Control" }, "k", function() awful.screen.focus_relative(-1) end),
  --
  -- mod + u, jump to the client that received the urgent hint first
  awful.key({ modkey, }, "u", awful.client.urgent.jumpto),
  --
  -- mod + tab, cycle backward through the client history, also raises client so it is on top
  awful.key({ modkey, }, "Tab", function()
    awful.client.focus.history.previous()
    if client.focus then
        client.focus:raise()
    end
  end),

  -- Standard program
  --
  -- mod + enter, spawn a terminal
  awful.key({ modkey, }, "Return", function() awful.util.spawn(terminal) end),
  --
  -- mod + control + r, restart awesome
  awful.key({ modkey, "Control" }, "r", awesome.restart),
  --
  -- mod + shift + q, quit awesome
  awful.key({ modkey, "Shift" }, "q", awesome.quit),
  --
  -- mod + l, increase the master width factor by 0.05
  awful.key({ modkey, }, "l", function() awful.tag.incmwfact(0.05) end),
  --
  -- mod + h, decrease the master width factor by 0.05
  awful.key({ modkey, }, "h", function() awful.tag.incmwfact(-0.05) end),
  --
  -- mod + shift + h, increase the number of master windows by 1
  awful.key({ modkey, "Shift" }, "h", function() awful.tag.incnmaster(1) end),
  --
  -- mod + shift + l, decrease the number of master windows by 1
  awful.key({ modkey, "Shift" }, "l", function() awful.tag.incnmaster(-1) end),
  --
  -- mod + control + h, increase the number of column windows by 1
  awful.key({ modkey, "Control" }, "h", function() awful.tag.incncol(1) end),
  -- 
  -- mod + control + l, decrease the number column windows by 1
  awful.key({ modkey, "Control" }, "l", function() awful.tag.incncol(-1) end),
  --
  -- mod + space, cycle forward through the layouts
  awful.key({ modkey, }, "space", function() awful.layout.inc(layouts, 1) end),
  --
  -- mod + shift + space, cycle backward through the layouts
  awful.key({ modkey, "Shift" }, "space", function() awful.layout.inc(layouts, -1) end),
  --
  -- mod + control + n, unminimize a client
  awful.key({ modkey, "Control" }, "n", awful.client.restore),
  --
  -- mod + r, display the main promptbox on whatever screen the cursor is at and execute 
  -- the entered command
  awful.key({ modkey }, "r", function() main_promptbox[mouse.screen]:run() end),
  -- 
  -- mod + x, display the main promptbox on whatever screen the cursor is at and execute 
  -- the entered Lua code
  awful.key({ modkey }, "x",
    function ()
      awful.prompt.run({ prompt = "Run Lua code: " },
      main_promptbox[mouse.screen].widget,
      awful.util.eval, nil,
      awful.util.getdir("cache") .. "/history_eval")
    end
  ),
  -- Menubar
  --
  -- mod + shift + p, show the menubar (the one that shows .desktop entries)
  awful.key({ modkey, "Shift" }, "m", function() menubar.show() end)
)

local clientkeys = awful.util.table.join(
  --
  -- mod + f, toggle focused client fullscreen mode
  awful.key({ modkey, }, "f", function(c) c.fullscreen = not c.fullscreen end),
  -- 
  -- mod + shift + c, kill focused client
  awful.key({ modkey, "Shift" }, "c", function(c) c:kill() end),
  --
  -- mod + control + space, toggle focused client floating mode
  awful.key({ modkey, "Control" }, "space", awful.client.floating.toggle),
  -- 
  -- mod + control + enter, swap focused client with client in master window
  awful.key({ modkey, "Control" }, "Return", function(c) c:swap(awful.client.getmaster()) end),
  --
  -- mod + o, move focused client to next screen
  awful.key({ modkey, }, "o", awful.client.movetoscreen),
  --
  -- mod + t, toggle focused client state of being on top of other windows
  awful.key({ modkey, }, "t", function (c) c.ontop = not c.ontop end),
  --
  -- mod + shift + n, minimize the focused client
  awful.key({ modkey, "Shift" }, "n", function (c)
    -- The client currently has the input focus, so it cannot be
    -- minimized, since minimized clients can't have the focus.
    c.minimized = true
  end),
  -- 
  -- mod + m, toggle focused client's maximize state
  awful.key({ modkey, }, "m", function (c)
    c.maximized_horizontal = not c.maximized_horizontal
    c.maximized_vertical = not c.maximized_vertical
  end)
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
  globalkeys = awful.util.table.join(
    globalkeys,
    --
    -- mod + 1-9, view tag only.
    awful.key({ modkey }, "#" .. i + 9, function()
      local screen = mouse.screen
      local tag = awful.tag.gettags(screen)[i]
      if tag then
        awful.tag.viewonly(tag)
      end
    end),
    --
    -- mod + control + 1-9, toggle selection of tag.
    awful.key({ modkey, "Control" }, "#" .. i + 9, function()
      local screen = mouse.screen
      local tag = awful.tag.gettags(screen)[i]
      if tag then
        awful.tag.viewtoggle(tag)
      end
    end),
    --
    -- mod + shift + 1-9, move client to tag.
    awful.key({ modkey, "Shift" }, "#" .. i + 9, function()
      if client.focus then
        local tag = awful.tag.gettags(client.focus.screen)[i]
        if tag then
          awful.client.movetotag(tag)
        end
      end
    end),
    --
    -- mod + control + shift + 1-9, toggle tag on focused client.
    awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9, function()
      if client.focus then
        local tag = awful.tag.gettags(client.focus.screen)[i]
        if tag then
          awful.client.toggletag(tag)
        end
      end
    end)
  )
end

local clientbuttons = awful.util.table.join(
  --
  -- left-click, focus/raise client
  awful.button({ }, 1, function(c) client.focus = c; c:raise() end),
  --
  -- mod + left-click, move client
  awful.button({ modkey }, 1, awful.mouse.client.move),
  --
  -- mod + right-click, resize client
  awful.button({ modkey }, 3, awful.mouse.client.resize)
)

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = {
  -- All clients will match this rule.
  { 
    rule = { },
    properties = { 
      border_width = beautiful.border_width,
      border_color = beautiful.border_normal,
      focus = awful.client.focus.filter,
      raise = true,
      keys = clientkeys,
      buttons = clientbuttons 
    } 
  },
  { 
    rule = { class = "MPlayer" },
    properties = { floating = true } 
  },
  { 
    rule = { class = "pinentry" },
    properties = { floating = true } 
  },
  { 
    rule = { class = "gimp" },
    properties = { floating = true } 
  },
  -- Set Firefox to always map on tags number 2 of screen 1.
  --{ 
  --  rule = { class = "Firefox" },
  --  properties = { tag = tags[1][2] } 
  --},
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c, startup)
  -- Enable sloppy focus
  c:connect_signal("mouse::enter", function(c)
    if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier and awful.client.focus.filter(c) then
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

  -- add a titlebar for every new "normal" or "dialog" client
  if c.type == "normal" or c.type == "dialog" then
    utils.add_titlebar(c)
  end

  -- if the layout isn't a floating one hide the titlebar
  if awful.layout.get(c.screen) ~= layout.floating then
    awful.titlebar.toggle(c)
  end

  -- connect a signal so that we know when the client's floating property changes
  -- and either hide or show the titlebar depending on the floating state
  c:connect_signal("property::floating", function(c)
    -- if the layout is floating mode the titlebar will already be displayed
    -- so disregard
    if awful.layout.get(c.screen) == layout.floating then
      return
    end

    -- disregard clients that aren't "normal" or "dialog"
    if c.type ~= "normal" and c.type ~= "dialog" then
      return
    end

    awful.titlebar.toggle(c)
  end)
end)

-- affects all clients
client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}

-- {{{ Utility functions
function utils.add_titlebar(c)
  -- buttons for the titlebar
  local buttons = awful.util.table.join(
    --
    -- left-click, focus the clicked client, raise it, and move it
    awful.button({ }, 1, function()
      client.focus = c
      c:raise()
      awful.mouse.client.move(c)
    end),
    --
    -- right-click, focus the clicked client, raise it, and resize it
    awful.button({ }, 3, function()
      client.focus = c
      c:raise()
      awful.mouse.client.resize(c)
    end)
  )

  -- Widgets that are aligned to the left
  local left_layout = wibox.layout.fixed.horizontal()
  -- add an icon widget for the application
  left_layout:add(awful.titlebar.widget.iconwidget(c))
  left_layout:buttons(buttons)

  -- Widgets that are aligned to the right
  local right_layout = wibox.layout.fixed.horizontal()
  -- add a floating button to the titlebar
  --right_layout:add(awful.titlebar.widget.floatingbutton(c))
  -- add a maximize button to the titlebar
  right_layout:add(awful.titlebar.widget.maximizedbutton(c))
  -- add a sticky button to the titlebar
  right_layout:add(awful.titlebar.widget.stickybutton(c))
  -- add an on top button to the titlebar
  right_layout:add(awful.titlebar.widget.ontopbutton(c))
  -- add a close button to the titlebar
  right_layout:add(awful.titlebar.widget.closebutton(c))

  -- The title goes in the middle
  local middle_layout = wibox.layout.flex.horizontal()
  local title = awful.titlebar.widget.titlewidget(c)
  title:set_align("center")
  middle_layout:add(title)
  middle_layout:buttons(buttons)

  -- Now bring it all together
  local layout = wibox.layout.align.horizontal()
  layout:set_left(left_layout)
  layout:set_right(right_layout)
  layout:set_middle(middle_layout)

  awful.titlebar(c):set_widget(layout)
end
-- }}}