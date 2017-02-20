local awful = require("awful")
local beautiful = require("beautiful")
local gears = require("gears")
local wibox = require("wibox")

local iconutils = require("utils.icon")

local exec = awful.spawn
local sexec = awful.spawn.with_shell
local easy_async = awful.spawn.easy_async

local cache = {}

local M = {}

local spacer_text

function markup_color (text, color)
	color = color or beautiful.fg_color
	return "<span foreground=\"" .. color .. "\">" .. text .. "</span>"
end

function M.spacer (text)
	if not cache.spacer then
		cache.spacer = wibox.widget{
			markup = beautiful.widget_spacer_text or " ",
			align = "center",
			valign = "center",
			widget = wibox.widget.textbox
		}
	end

	return cache.spacer
end

--- Volume display with revealable slider to adjust levels.
-- Theme variables:
--	volume_slider_color
--	volume_slider_handle_color
--	volume_slider_width
--	volume_slider_handle_size
function M.volume (device_name)
	device_name = device_name or "Master"

	if cache.volume then
		return cache.volume
	end

	local slider
	local timer
	local vol_level
	local script_cmd = awful.util.getdir("config") .. "scripts/volume " .. device_name

	local buttons = awful.util.table.join(
		-- left-click
		awful.button(
			{ }, 
			1, 
			function () 
				slider.visible = not slider.visible
			end
		),
		-- right-click
		awful.button({ }, 3, function () exec("pavucontrol") end)
	)

	local icon = wibox.widget{
		markup = markup_color(iconutils.volume .. " ", beautiful.widget_icon_color),
		align = "center",
		valign = "center",
		widget = wibox.widget.textbox,
	}
	icon:buttons(buttons)

	local status = wibox.widget{
		align = "center",
		valign = "center",
		widget = wibox.widget.textbox
	}
	status:buttons(buttons)

	slider = wibox.widget {
		bar_shape = gears.shape.rounded_rect,
		bar_height = 3,
		bar_color = beautiful.volume_slider_color or beautiful.fg_urgent,
		handle_color = beautiful.volume_slider_handle_color or beautiful.fg_urgent,
		handle_shape = gears.shape.circle,
		handle_border_width = 0,
		handle_width = beautiful.volume_slider_handle_size or 10,
		forced_width = beautiful.volume_slider_width or 50,
		value = 25,
		visible = false,
		maximum = 100,
		minimum = 0,
		widget = wibox.widget.slider,
	}

	slider:connect_signal("widget::redraw_needed", function () 
		status.text = slider.value .. "%"
		sexec("amixer set " .. device_name .. " " .. slider.value .. "% &>/dev/null")
	end)

	local function update_status ()
		easy_async(script_cmd, function (stdout, stderr, exitreason, exitcode)
			if exitcode > 0 then
				status.text = ":("
			end
			vol_level = tonumber(stdout)
			status.text = vol_level .. "%"
			slider.value = vol_level
		end)
	end

	-- initialize text
	update_status()

	-- update every 40ish seconds
	timer = gears.timer({ timeout = 47 })
	timer:connect_signal("timeout", update_status)
	timer:start()

	local widget = wibox.widget{
		layout = wibox.layout.fixed.horizontal,
		icon,
		status,
		slider,
		M.spacer()
	}

	widget:connect_signal("mouse::enter", function ()
		timer:stop()
	end)

	widget:connect_signal("mouse::leave", function ()
		timer:start()
		slider.visible = false
	end)

	cache.volume = widget

	return cache.volume
end

function M.clock () 
	if not cache.clock then
		local icon = wibox.widget{
			markup = markup_color(iconutils.clock .. " ", beautiful.widget_icon_color),
			align = "center",
			valign = "center",
			widget = wibox.widget.textbox
		}

		local textclock = wibox.widget.textclock()

		cache.clock = wibox.widget{
			layout = wibox.layout.fixed.horizontal,
			icon,
			textclock,
			M.spacer()
		}
	end

	return cache.clock
end

function M.pacman ()
	if not cache.pacman then
		local buttons = awful.button(
			{},
			1,
			function () sexec("pacman -Qu | xmessage -file - -nearmouse") end
		)

		local icon = wibox.widget{
			markup = markup_color(iconutils.tux .. " ", beautiful.widget_icon_color),
			align = "center",
			valign = "center",
			widget = wibox.widget.textbox
		}
		icon:buttons(buttons)

		local status = wibox.widget{
			align = "center",
			valign = "center",
			widget = wibox.widget.textbox
		}
		status:buttons(buttons)

		local function update_status ()
			easy_async("zsh -c 'pacman -Qu | wc -l'", function (stdout, stderr, exitreason, exitcode) 
				if exitcode > 0 then
					status.text = ":("
					return
				end
				status.text = stdout
			end)
		end

		-- initialize text
		update_status()

		-- update every hour
		local timer = gears.timer({ timeout = 3637 })
		timer:connect_signal("timeout", update_status)
		timer:start()

		cache.pacman = wibox.widget{
			layout = wibox.layout.fixed.horizontal,
			icon,
			status,
			M.spacer()
		}
	end

	return cache.pacman
end


return M
