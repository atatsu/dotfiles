local awful = require("awful")
local gears = require("gears")
local naughty = require("naughty")

local M = {}

--[[
          
--]]
local friendly = {
	chat = "",
	steam = "",
	web = "",
	dev = "",
	games = "",
	music = "",
	devalt = "",
	misc = "",
}

M.friendly_tag_names = friendly

M.tags = {}

--[[
local screens_by_randr = {}
(function () 
	local tags_by_randr = {
		["DVI-I-1"] = { friendly.dev, friendly.games, friendly.misc },
		["HDMI-0"] = { friendly.music, friendly.misc },
		["DVI-D-0"] = { friendly.devalt, friendly.misc },
	}

	for s in screen do
		for screen_name, _ in pairs(s.outputs) do 
			M.tags[s.index] = tags_by_randr[screen_name]
			screens_by_randr[screen_name] = s
		end
	end
end)()
--]]


-- The order in which displays are handled by `xrandr` determines their index!
-- xrandr 
--   --output DVI-I-1 --primary --auto                         -- 1
--   --output DVI-D-0 --auto --right-of DVI-I-1 --rotate left  -- 2
--   --output HDMI-0 --auto --left-of DVI-I-                   -- 3
M.tags[1] = { friendly.dev, friendly.games, friendly.misc }
M.tags[2] = { friendly.devalt, friendly.misc }
M.tags[3] = { friendly.music, friendly.misc }

M.left_screen = (function () 
	if screen:count() > 1 then
		for s in screen do
			if s.index == 3 then
				return s
			end
		end
		--return screens_by_randr["HDMI-0"]
	end

	return screen.primary
end)()

M.right_screen = (function () 
	if screen:count() > 1 then
		for s in screen do
			if s.index == 2 then
				return s
			end
		end
		--return screens_by_randr["DVI-D-0"]
	end

	return screen.primary
end)()

function M.chat_rule_callback (c)
	local chat_tag = awful.tag.find_by_name(M.left_screen, friendly.chat)

	if not chat_tag then
		chat_tag = awful.tag.add(
			friendly.chat,
			{
				screen = M.left_screen,
				layout = awful.layout.suit.tile,
				volatile = true
			}
		)

		chat_tag.master_width_factor = 0.8

		-- check if we have a web tag, and if so don't cut in line!
		local web_tag = awful.tag.find_by_name(M.left_screen, friendly.web)	
		chat_tag.index = web_tag and web_tag.index + 1 or 1

		naughty.notify({
			preset = naughty.config.presets.normal,
			title = "created new tag",
			text = chat_tag.name .. "  (chat) [ s = " .. tostring(M.left_screen.index) .. " ]"
		})
	end

	awful.rules.execute(c, { tag = chat_tag })

	-- ignore the mumble connection dialog
	if c.floating then
		return
	end

	-- now figure out whether it's mumble or weechat and set 
	-- the proper one as master/slave while ignoring the mumble
	-- connection dialog
	if c.name:lower():find("mumble") ~= nil then
		awful.client.setslave(c)
		return
	end

	-- weechat
	awful.client.setmaster(c)
end

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
			text = web_tag.name .. "  (web) [ s = " .. tostring(M.left_screen.index) .. " ]"
		})

		-- web comes first!
		web_tag.index = 1
	end

	awful.rules.execute(c, { tag = web_tag })
	web_tag:view_only()
	awful.screen.focus(M.left_screen.index)
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
		
		local misc_tag = awful.tag.find_by_name(screen.primary, friendly.misc)
		if steam_tag.index == #screen.primary.tags and misc_tag then
			steam_tag:swap(misc_tag)
		end

		naughty.notify({ 
			preset = naughty.config.presets.normal,
			title = "created new tag",
			text = steam_tag.name .. "  (steam) [ s = " .. tostring(screen.primary.index) .. " ]"
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
