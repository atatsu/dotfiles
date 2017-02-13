local awful = require("awful")
local beautiful = require("beautiful")
local gears = require("gears")
local wibox = require("wibox")

local sexec = awful.spawn.with_shell
local easy_async = awful.spawn.easy_async

local cache = {}

local M = {}

local spacer_text

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

function M.clock () 
	if not cache.clock then
		local icon = wibox.widget{
			markup = " ",
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
			markup = " ",
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
