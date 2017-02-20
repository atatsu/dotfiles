local awful = require("awful")
local beautiful = require("beautiful")
local gears = require("gears")

local utils = require("utils")

local keys = require("prefs.keys")
local buttons = require("prefs.buttons")

local ruleutils = utils.rule
local screenutils = utils.screen
local iconutils = utils.icon

local clientkeys = keys.client
local clientbuttons = buttons.client

local is_setup = false

local M
M = {
	init = function ()
		if is_setup then return end
		is_setup = true

		local r = {}
		for k, v in pairs(M) do
			if k ~= "init" then
				r[#r+1] = v
			end
		end

		awful.rules.rules = r
	end
}

-- {{{ Shit that should be floated and placed nicely in the screen center
M.float_center = {
	rule_any = {
		class = {
			"Xmessage",
		},
		instance = {
			"xmessage"
		},
		name = {
		},
	},
	properties = { floating = true },
	callback = function (c)
		local f = (awful.placement.centered)
		f(c)
	end
}
-- }}}

-- {{{ Steam is a fuckin' bitch. Most of its windows don't spawn with
-- the appropriate info and consequently you need timeouts with callbacks 
-- for most of them.
M.steam = {
	rule = {
		class = "Steam",
		instance = "Steam"
	},
	callback = ruleutils.dynamic_tag(
		screen.primary,
		iconutils.steam,
		function (c, tag, s)
			-- The 'Friends' window and main library window spawn at the same time
			-- which seems to fuck up the rule application. Consequently the Friends
			-- window is properly placed on the new tag but the library window just kinda
			-- pops up wherever the fuck it feels like. Below we're delaying the rule
			-- execution for the main library window so that it can be placed properly
			if c.name == "Steam" and not c.floating then
				c.hidden = true
				gears.timer.weak_start_new(1, function () 
					awful.rules.execute(c, { tag = tag })
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
				gears.timer.weak_start_new(1, function ()
					awful.rules.execute(c, { tag = tag })

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
			elseif c.name:find("News") ~= nil then
				c.floating = true
			end
		end,
		{ layout = awful.layout.suit.tile.left, master_width_factor = 0.75 },
		{ before = iconutils.misc }
	)
}
-- }}}

-- {{{ Send chromium and qutebrowser to a newly created, volatile tag
M.web = {
	rule_any = {
		class = {
			"qutebrowser",
			"Chromium"
		},
		instance = {
			"qutebrowser",
			"chromium"
		},
	},
	properties = { switchtotag = true },
	callback = ruleutils.dynamic_tag(
		screenutils.get_by_index(3),
		iconutils.web,
		function (c, tag, s)
			mouse.coords({ x = c.x, y = c.y})
		end,
		{ index = 1, master_width_factor = 0.75, layout = awful.layout.suit.magnifier }
	)
}
-- }}}

-- {{{ Send ncmpcpp to a newly created, volatile tag
M.music = {
	rule_any = {
		class = {
			"ncmpcpp",
		},
		instance = {
			"ncmpcpp-visualizer",
			"ncmpcpp-playlist",
		},
		name = {
			"album-art",
		}
	},
	callback = ruleutils.dynamic_tag(
		screenutils.get_by_index(3),
		iconutils.music,
		function (c, t, s)
			print(c.name)
			if c.instance == "ncmpcpp-visualizer" then
				awful.client.setslave(c)
				return
			elseif c.name:lower() == "album-art" then
				-- feh
				-- we don't want spawning feh windows to steal the focus
				c.focusable = false

				awful.client.setslave(c)
				awful.client.setwfact(0.2, c)
				t:view_only()
				return
			end

			-- ncmpcpp-playlist
			awful.client.setmaster(c)
		end,
		{ gap = 5, master_width_factor = 0.7, layout = awful.layout.suit.tile.bottom },
		{ before = iconutils.misc }
	)
}
-- }}}

-- {{{ Send weechat and mumble to a newly created, volatile tag
M.chat = {
	rule_any = {
		class = {
			"weechat",
			"Mumble",
		},
		instance = {
			"weechat",
			"mumble",
		}
	},
	--callback = ruleutils.chat_rule_callback
	callback = ruleutils.dynamic_tag(
		screenutils.get_by_index(3), 
		iconutils.chat, 
		function (c, tag, s)
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
		end,
		{ master_width_factor = 0.8 },
		{ after = iconutils.web, fallback = 1 }
	)
}
-- }}}

-- {{{ Prefab from stock config

-- {{{ All clients will match this rule
M.all = {
	rule = { },
	properties = { 
		border_width = beautiful.border_width,
		border_color = beautiful.border_normal,
		focus = awful.client.focus.filter,
		raise = true,
		keys = clientkeys,
		buttons = clientbuttons,
		screen = awful.screen.preferred,
		placement = awful.placement.no_overlap+awful.placement.no_offscreen
	},
}
-- }}}

-- {{{ Floating clients
M.floating = {
	rule_any = {
		instance = {
			"DTA",	-- Firefox addon DownThemAll.
			"copyq",	-- Includes session name in class.
		},
		class = {
			"Arandr",
			"Gpick",
			"Kruler",
			"MessageWin",  -- kalarm.
			"Sxiv",
			"Wpa_gui",
			"pinentry",
			"veromix",
			"xtightvncviewer"
		},
		name = {
			"Event Tester",  -- xev.
		},
		role = {
			"AlarmWindow",	-- Thunderbird's calendar.
			"pop-up",				-- e.g. Google Chrome's (detached) Developer Tools.
		}
	}, 
	properties = { floating = true }
}
-- }}}

-- {{{ Add titlebars to normal clients and dialogs
M.titlebars = {
	rule_any = {
		type = { "normal", "dialog", "utility" }
	}, 
	properties = { titlebars_enabled = true }
}
-- }}}

-- }}}

return M
