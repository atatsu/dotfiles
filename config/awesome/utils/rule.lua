local awful = require("awful")
local gears = require("gears")
local naughty = require("naughty")

local iconutils = require("utils.icon")
local screenutils = require("utils.screen")

local M = {}

local left_screen = screenutils.get_by_index(3)
local right_screen = screenutils.get_by_index(2)

function M.dynamic_tag (s, tag_name, callback, props, order)
	s = s or screen.primary
	tag_name = tag_name or 'dynamic tag'
	props = props or {}
	props.screen = s
	props.layout = props.layout or awful.layout.suit.tile
	if props.volatile == nil then
		props.volatile = true
	end

	return function (c)
		local tag = awful.tag.find_by_name(s, tag_name)

		if not tag then
			tag = awful.tag.add(tag_name, props)

			if order and order.after then
				local after_tag = awful.tag.find_by_name(s, order.after)
				tag.index = after_tag and after_tag.index + 1 or order.fallback
			elseif order and order.before then
				local before_tag = awful.tag.find_by_name(s, order.before)
				tag.index = before_tag and before_tag.index or order.fallback
			end

			naughty.notify({
				preset = naughty.config.presets.normal,
				title = "created new tag",
				text = tag.name .. " [ s " .. tostring(s.index) .. " ]"
			})

		end

		awful.rules.execute(c, { tag = tag })

		callback(c, tag, s)

	end
end

return M
