local awful = require("awful")
local beautiful = require("beautiful")
local gears = require("gears")
local wibox = require("wibox")

local icons = require("prefs.icons")

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

function M.color_text (text, color, opts)
	opts = opts or {}
	return wibox.widget{
		markup = markup_color(text, color),
		align = "center",
		valign = "center",
		opacity = opts.opacity,
		widget = wibox.widget.textbox
	}
end

function M.color_text_surface (text, color, opts)
	opts = opts or {}
	w = opts.width or 15
	h = opts.height or 15
	local widget = M.color_text(text, color, opts)
	local surface = gears.surface.widget_to_surface(widget, w, h)
	return surface
end

--- Volume display with revealable slider to adjust levels.
-- @param device_name The name of the device to control (such as 'Master')
--- Theme variables:
--	volume_slider_color
--	volume_slider_handle_color
--	volume_slider_width
--	volume_slider_handle_size
function M.volume (device_name)
	if cache.volume then
		return cache.volume
	end

	device_name = device_name or "Master"
	local script_cmd = awful.util.getdir("config") .. "scripts/volume " .. device_name
	local is_muted = false

	local icon
	local status
	local slider
	local timer
	local vol_level

	local function update_display_widgets (level)
		slider.value = level
		status.text = level .. "%"
	end

	local function set_volume_level (level)
		update_display_widgets(level)
		sexec("amixer set " .. device_name .. " " .. level .. "% &>/dev/null")
	end

	local function adjust_volume_level (amount)
		level = vol_level + amount
		update_display_widgets(level)
		sexec("amixer set " .. device_name .. " " .. level .. "% &>/dev/null")
	end

	-- Called to get the initial volume level. Called periodically
	-- afterwards to check if the volume level changed via other
	-- means.
	local function update_status ()
		easy_async(script_cmd, function (stdout, stderr, exitreason, exitcode)
			if exitcode > 0 then
				status.text = ":("
			end

			local level = tonumber(stdout)
			if is_muted and level == 0 then
				-- we're muted so don't bother updating anything
				return
			elseif is_muted and level ~= 0 then
				-- volume was adjusted somewhere that wasn't this widget, so
				-- consider us no longer muted
				is_muted = false
			end

			vol_level = level
			update_display_widgets(level)
		end)
	end

	icon = M.color_text(icons.volume .. " ", beautiful.widget_icon_color)

	status = wibox.widget{
		align = "center",
		valign = "center",
		widget = wibox.widget.textbox
	}

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

	local margin = wibox.container.margin(slider, 10, 10, nil, nil, nil, false)

	slider:connect_signal("widget::redraw_needed", function () 
		if is_muted and slider.value == 0 then
			-- ignore as this redraw is the act of muting and setting the slider
			-- to 0
			return
		end

		vol_level = slider.value
		set_volume_level(vol_level)
	end)

	-- initialize text
	update_status()

	-- update every 40ish seconds
	timer = gears.timer({ timeout = 47 })
	timer:connect_signal("timeout", update_status)
	timer:start()

	local buttons = awful.util.table.join(
		--[[
		-- left-click
		awful.button({ }, 1, function () 
			slider.visible = not slider.visible
		end),
		--]]
		-- middle-click
		awful.button({ }, 2, function () 
			-- if the slider is at 0 assume we've already muted it and restore it
			-- to its previously held value
			is_muted = not is_muted

			if is_muted then
				set_volume_level(0)
				-- update icon to reflect muted status
				icon:set_markup_silently(markup_color(icons.volumeoff .. " ", beautiful.widget_icon_color))
				status.text = ""
				slider.visible = false
				return
			end

			icon:set_markup_silently(markup_color(icons.volume .. " ", beautiful.widget_icon_color))
			set_volume_level(vol_level)
			slider.visible = true
		end),
		-- right-click
		awful.button({ }, 3, function () exec("pavucontrol") end),
		awful.button({ }, 4, function () adjust_volume_level(1) end),
		awful.button({ }, 5, function () adjust_volume_level(-1) end)
	)

	local widget = wibox.widget{
		layout = wibox.layout.fixed.horizontal,
		icon,
		status,
		margin,
		M.spacer()
	}
	widget:buttons(buttons)
	local tooltip = awful.tooltip({
		objects = { widget },
		timer_function = function ()
			return device_name
		end,
	})

	widget:connect_signal("mouse::enter", function ()
		timer:stop()

		-- if we're muted don't bother displaying the slider
		if is_muted then return end
		slider.visible = true
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
		local icon = M.color_text(icons.clock .. " ", beautiful.widget_icon_color)

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

		local icon = M.color_text(icons.tux .. " ", beautiful.widget_icon_color)
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

function M.systray ()
	if cache.systray then
		return cache.systray
	end

	local systray = wibox.widget.systray()
	cache.systray = wibox.widget{
		layout = wibox.layout.fixed.horizontal,
		systray,
		M.spacer()
	}

	return cache.systray
end

return M
