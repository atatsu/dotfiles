local awful = require("awful")
local wibox = require("wibox")
local vicious = require("vicious")
local beautiful = require("beautiful")

-- function aliases
local pread = awful.util.pread
local sexec = awful.util.spawn_with_shell
local exec = awful.util.spawn

-- initialized after module loaded
local spacer_text

local M = {}

-- {{{ Spacer widget
local create_spacer = function()
  local spacer = wibox.widget.textbox()
  spacer:set_text(spacer_text)
  M.spacer = spacer
end
-- }}}

-- {{{ Pacman updates
function M.add_pacman(layout)
  -- icon
  local pacicon = wibox.widget.imagebox()
  pacicon:set_image(beautiful.widget_pacman)
  -- widget
  local pacwidget = wibox.widget.textbox()
  local pacupdate = function()
    return pread("pacman -Qu | wc -l")
  end
  pacwidget:set_text(pacupdate())
  -- buttons
  -- left-click, xmessage popup with packages to update
  local pacbuttons = awful.button(
    {}, 
    1, 
    function() sexec("pacman -Qu | xmessage -file - -nearmouse") end
  )
  -- now bind the buttons to the icon and widget
  pacicon:buttons(pacbuttons)
  pacwidget:buttons(pacbuttons)
  -- timer to update the widget text periodically
  local pactimer = timer({timeout = 3637})
  pactimer:connect_signal(
    "timeout",
    function() pacwidget:set_text(pacupdate()) end
  )
  pactimer:start()

  layout:add(pacicon)
  layout:add(pacwidget)
  layout:add(M.spacer)
end
-- }}}

-- {{{ Volume widget
function M.add_volume(layout)
  -- set icon
  local volicon = wibox.widget.imagebox()
  volicon:set_image(beautiful.widget_volume)
  -- create and register widget
  local volwidget = wibox.widget.textbox()
  vicious.register(volwidget, vicious.widgets.volume, "$1", 13, "Master")

  layout:add(volicon)
  layout:add(volwidget)
  layout:add(M.spacer)
end
-- }}}

-- {{{ MPD widget
function M.add_mpd(layout)
  -- set icon
  local mpdicon = wibox.widget.imagebox()
  mpdicon:set_image(beautiful.widget_mpd)
  -- create and register widget
  local mpdwidget = wibox.widget.textbox()
  vicious.register(mpdwidget, vicious.widgets.mpd, function(mpdwidget, args)
    if args["{state}"] == "Stop" then
      return " - "
    else
      return args["{Artist}"] .. ' - ' .. args["{Title}"]
    end
  end, 11)

  layout:add(mpdicon)
  layout:add(mpdwidget)
  layout:add(M.spacer)
end
-- }}}

-- {{{ CPU widget
function M.add_cpu(layout)
  -- set icon
  local cpuicon = wibox.widget.imagebox()
  cpuicon:set_image(beautiful.widget_cpu)
  -- create and register widget
  local cpuwidget = awful.widget.graph()
  cpuwidget:set_width(40)
  cpuwidget:set_background_color(beautiful.bg_normal)
  cpuwidget:set_color({
    type = "linear",
    from = {0, 0},
    to = {10, 0},
    stops = {
      {0, "#ff5656",},
      {0.5, "#88a175"},
      {1, "#aecf96"},
    },
  })
  vicious.register(cpuwidget, vicious.widgets.cpu, "$1")

  layout:add(cpuicon)
  layout:add(cpuwidget)
  layout:add(M.spacer)
end
-- }}}

-- {{{ Memory widget
function M.add_mem(layout)
  -- set icon
  local memicon = wibox.widget.imagebox()
  memicon:set_image(beautiful.widget_mem)
  -- create and register widget
  local memwidget = wibox.widget.textbox()
  vicious.register(memwidget, vicious.widgets.mem, "$1% ($2MB/$3MB)", 13)

  layout:add(memicon)
  layout:add(memwidget)
  layout:add(M.spacer)
end
-- }}}

-- {{{ Clock/date widget
function M.add_clock(layout)
  -- set icon
  local clockicon = wibox.widget.imagebox()
  clockicon:set_image(beautiful.widget_clock)
  -- create widget
  local clockwidget = awful.widget.textclock()

  layout:add(clockicon)
  layout:add(clockwidget)
  layout:add(M.spacer)
end
-- }}}

-- {{{ Disk usage widget
--- Add a widget showing disk space usage.
-- Adds a widget that when clicked displays a pop-up displaying
-- each mount point along with its size, used, avail, and use%, as 
-- given with the `df` command. If no `width` is supplied will
-- try go determine best width based on current theme font size.
-- Uses `theme.widget_disk` for its icon. If `theme.widget_disk_[2-7]`
-- are available it will use them next to each listing depending
-- disk % use for a graphical representation of how much disk space
-- is being used.
-- @param layout A layout widget from `wibox.layout.*`
-- @param mounts An array of mountpoints
-- @param width Width of the pop-up (optional)
function M.add_diskusage(layout, mounts, width)
  -- command to get partition size, used, avail, and use%
  local cmd_template = "df -h %s | tail -n 1 | awk '{print $2, $3, $4, $5}'"
  -- set icon
  local diskicon = wibox.widget.imagebox()
  diskicon:set_image(beautiful.widget_disk)
  -- buttons
  -- left-click, show a pop-up menu of mount points and their max capacity and filled space
  -- if the menu is already open, close it
  local _disks_popup
  local diskbuttons = awful.button(
    {},
    1, 
    function()
      if _disks_popup then
        _disks_popup:hide()
        _disks_popup = nil
      else
        -- our table that all the "menu" entries will be stored in
        local items = {}

        -- table used in determining the max column lengh so that 
        -- everything can be formatted nicely and have a semblence of columns 
        -- while being displayed
        local column_len = {0, 0, 0, 0, 0}
        
        -- table to store all the command output values in
        -- initialized with our column headers
        local values = {
          {"Mount point", "Size", "Used", "Avail", "Use%"}
        }
        for i, v in ipairs(mounts) do
          local cmd = string.format(cmd_template, v)
          local output = pread(cmd)
          local found, _, size, used, avail, use_percent = output:find(
            "^([0-9.]+%u*) ([0-9.]+%u*) ([0-9.]+%u*) ([0-9.]+%%)"
          )
          if not found then
            -- error with command
            values[#values+1] = {v, "?", "?", "?", "?"}
          else
            values[#values+1] = {v, size, used, avail, use_percent}
          end
        end

        -- now determine what each column's length needs to be
        for _, row in ipairs(values) do
          for i, v in ipairs(row) do
            if v:len() > column_len[i] then
              column_len[i] = v:len()
            end
          end
        end

        -- now that we have the length each column needs to be format everything
        -- into an items table that can be used for the menu
        for _, row in ipairs(values) do
          local item_row = {}
          local usage_icon
          for i, v in ipairs(row) do
            local len = column_len[i]
            local diff = column_len[i] - v:len()
            local col = v .. string.rep(" ", diff)
            item_row[#item_row+1] = col

            -- select an icon to use based on use%
            if not usage_icon then
              local found, _, use_percent = v:find("^([0-9.]+)%%$")
              if found then
                use_percent = tonumber(use_percent)
                if use_percent < 15 then
                  usage_icon = beautiful.widget_disk
                elseif use_percent < 30 then
                  usage_icon = beautiful.widget_disk_2
                elseif use_percent < 45 then
                  usage_icon = beautiful.widget_disk_3
                elseif use_percent < 60 then
                  usage_icon = beautiful.widget_disk_4
                elseif use_percent < 75 then
                  usage_icon = beautiful.widget_disk_5
                elseif use_percent < 90 then
                  usage_icon = beautiful.widget_disk_6
                else
                  usage_icon = beautiful.widget_disk_7
                end
              end
            end
          end
          items[#items+1] = {table.concat(item_row, " "), "", usage_icon}
        end

        if not width then
          -- determine how wide our "menu" needs to be based on the longest row
          local menu_width = 0
          for _, row in ipairs(items) do
            local row_text = row[1]
            if row_text:len() > menu_width then
              menu_width = row_text:len()
            end
          end

          local theme = beautiful.get()
          local font = theme.font
          local found, _, size = font:find("^.+ ([0-9]*)$")
          if not found then
            width = 250
          else
            width = size * menu_width
          end
        end

        _disks_popup = awful.menu({
          items = items,
          theme = {width = width}
        })
        _disks_popup:show()
      end
    end
  )
  diskicon:buttons(diskbuttons)

  layout:add(diskicon)
  layout:add(M.spacer)
end
-- }}}

function M.init(_spacer_text)
  spacer_text = _spacer_text or " "

  create_spacer()
end

return M
