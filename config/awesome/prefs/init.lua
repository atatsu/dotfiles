local beautiful = require("beautiful")
local naughty = require("naughty")

local config = require("prefs.config")

local M = { }

local mods = {}

setmetatable(M, {
	-- This is here so that order doesn't matter in terms of 
	-- initialization. If a mod requires another mod it will
	-- magically be included.
	__index = function (self, key)
		if mods[key] ~= nil then
			return mods[key]
		end

		local mod
		if pcall(function () 
			mod = require("prefs." .. key)
		end) then
			if mod.init then mod.init() end
			mods[key] = mod
			return mod
		end

		naughty.notify({
			preset = naughty.config.presets.critical,
			title = "prefs import failure",
			text = "unable to import prefs." .. key
		})
	end
})

function M.init ()
	beautiful.init(config.theme)
	-- Even with the above shit still calling `init()` on stuff
	-- that needs it. Because you don't have to worry! If `init()`
	-- has already been called nothing will happen. If called new
	-- and mod requires another, it'll get included.
	M.rules.init()
	M.keys.init()
	M.buttons.init()
	M.signals.init()
	M.widgets.init()
end

return M
