local naughty = require("naughty")
local awful = require("awful")
local wibox = require("wibox")

local M = {}

function M.get_tag_by_name(tag_name, tags)
  for s = 1, screen.count() do
    for _, tag in ipairs(tags[s]) do
      if tag.name == tag_name then
        return tag
      end
    end
  end

  naughty.notify({
    preset = naughty.config.presets.normal,
    title = "Tag not found",
    text = string.format("Tag with name '%s' not found", tag_name)
  })
end

function M.add_titlebar(c)
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

return M
