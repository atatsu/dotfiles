local awful = require("awful")
local gears = require("gears")
local naughty = require("naughty")

local M = {}

--[[
          
--]]
local friendly = {
	--["chat"] = "",
	["chat"] = "",
	["steam"] = "",
	["web"] = "",
	["dev"] = "",
	["games"] = "",
	["music"] = "",
	["devalt"] = "",
	["misc"] = "",
}

M.friendly_tag_names = friendly

M.tags = {}

-- xrandr info is used to determine screen order remember!
M.tags[1] = { friendly.dev, friendly.games, friendly.misc }
M.tags[2] = { friendly.chat, friendly.music, friendly.misc }
M.tags[3] = { friendly.devalt, friendly.misc }

M.left_screen = (function () 
	if screen:count() > 1 then
		for s in screen do
			if s.index == 2 then
				return s
			end
		end
	end

	return screen.primary
end)()

M.right_screen = (function () 
	if screen:count() > 1 then
		for s in screen do
			if s.index == 3 then
				return s
			end
		end
	end

	return screen.primary
end)()

function M.web_rule_callback (c)
	local web_tag = awful.tag.find_by_name(M.left_screen, friendly.web)

	if not web_tag then
		web_tag = awful.tag.add(
			friendly.web,
			{
				screen = M.left_screen,
				layout = awful.layout.suit.magnifier,
				volatile = true
			}
		)

		web_tag.master_width_factor = 0.85

		naughty.notify({
			preset = naughty.config.presets.normal,
			title = "created new tag",
			text = web_tag.name .. "  (web) [" .. tostring(M.left_screen.index) .. "]"
		})
	end

	awful.rules.execute(c, { tag = web_tag })
	web_tag:view_only()
	awful.screen.focus(M.left_screen.index)
	-- web comes first!
	web_tag.index = 1
end

function M.steam_rule_callback (c)
	-- first check if the tag already exists
	local steam_tag = awful.tag.find_by_name(screen.primary, friendly.steam)

	if not steam_tag then
		steam_tag = awful.tag.add(
			friendly.steam,
			{
				screen = screen.primary,
				layout = awful.layout.suit.tile.left,
				volatile = true
			}
		)
		steam_tag.master_width_factor = 0.75

		-- We don't want our nicely created steam tag to be after that 
		-- dreadful 'misc' tag... so swap if necessary.
		
		misc_tag = awful.tag.find_by_name(screen.primary, friendly.misc)
		if steam_tag.index == #screen.primary.tags and misc_tag then
			steam_tag:swap(misc_tag)
		end

		naughty.notify({ 
			preset = naughty.config.presets.normal,
			title = "created new tag",
			text = steam_tag.name .. "  (steam) [" .. tostring(screen.primary.index) .. "]"
		})
	end

	-- The 'Friends' window and main library window spawn at the same time
	-- which seems to fuck up the rule application. Consequently the Friends
	-- window is properly placed on the new tag but the library window just kinda
	-- pops up wherever the fuck it feels like. Below we're delaying the rule
	-- execution for the main library window so that it can be placed properly
	if c.name == "Steam" and not c.floating then
		c.hidden = true
		gears.timer.weak_start_new(0.5, function () 
			awful.rules.execute(c, { tag = steam_tag })
			c.hidden = false
			awful.client.setmaster(c)
			--steam_tag:view_only()
		end)
		return
	-- Fun fact! The Chat window intially opens with the name 'Untitled'!
	-- So delay it's resolution as well! I'm sure other windows have
	-- similar douchy behavior so I'll have to deal with them at some point.
	elseif c.name == "Untitled" then
		c.hidden = true
		gears.timer.weak_start_new(0.5, function ()
			awful.rules.execute(c, { tag = steam_tag })

			if c.name:find("Chat") ~= nil then
				-- Yay! We have the chat window!
				c.hidden = false
				awful.client.setslave(c)
				return
			end

			-- If it ain't chat just assume it's some other fuckin' thing we want
			-- floating anyway.
			c.hidden = false
			c.floating = true
			c:raise()
		end)
		return
	end

	awful.rules.execute(c, { tag = steam_tag })

	if c.name:find("News") ~= nil then
		c.floating = true
	--[[
	else
		naughty.notify({ 
			preset = naughty.config.presets.normal,
			title = "unknown name",
			text = c.name
		})
	--]]
	end
end

return M
