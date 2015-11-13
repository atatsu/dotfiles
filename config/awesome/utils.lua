local naughty = require("naughty")
local awful = require("awful")
local wibox = require("wibox")
local screen_overrides = {}

if awful.util.checkfile(awful.util.getdir("config") .. "screenoverrides.lua") then
	screen_overrides = require("screenoverrides")
end

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

function M.screen_override(s)
	local override = screen_overrides[s]
	return override or s
end

function M.next_screen()
	local cur_scr = screen_overrides[mouse.screen]
	local next_scr = screen_overrides[cur_scr + 1]
	if next_scr > screen.count() then
		next_scr = 1
	end

	return screen_overrides[next_scr] or next_scr
end

function M.prev_screen()
	local cur_scr = screen_overrides[mouse.screen]
	local prev_scr = cur_scr - 1
	if prev_scr < 1 then
		prev_scr = screen.count()
	end

	return screen_overrides[prev_scr] or prev_scr
end

function M.next_screen_relative()
	local cur_scr_awesome = mouse.screen -- 2
	local cur_scr_override = screen_overrides[mouse.screen] -- 3

	local intended_next = cur_scr_override + 1
	if intended_next > screen.count() then
		-- need to go to the first screen
		intended_next = 1
	end

	local jumps = 1
	for i = 1, screen.count() do
		intended_awesome = cur_scr_awesome + i
		if intended_awesome > screen.count() then
			intended_awesome = intended_awesome - screen.count()
		end

		if screen_overrides[intended_awesome] == intended_next then
			return jumps
		end

		jumps = jumps + 1
	end
end

function M.prev_screen_relative()
	local cur_scr_awesome = mouse.screen
	local cur_scr_override = screen_overrides[mouse.screen]

	local intended_prev = cur_scr_override - 1
	if intended_prev < 1 then
		-- need to go to last screen
		intended_prev = screen.count()
	end

	local jumps = 1
	for i = 1, screen.count() do
		intended_awesome = cur_scr_awesome + i
		if intended_awesome > screen.count() then
			intended_awesome = intended_awesome - screen.count()
		end

		if screen_overrides[intended_awesome] == intended_prev then
			return jumps
		end

		jumps = jumps + 1
	end
end

return M
