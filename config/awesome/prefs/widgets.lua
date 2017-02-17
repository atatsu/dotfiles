local awful = require("awful")
local beautiful = require("beautiful")
local hotkeys_popup = require("awful.hotkeys_popup").widget
--local menubar = require("menubar")

local config = require("prefs.config")

local is_setup = false

local M = {
	init = function ()
		if is_setup then return end
	end
}

local awesome_menuitems = {
	{ "syela", {
		{ " tmnt", "chromium https://www.youtube.com/results?search_query=teenage+mutant+ninja+turtles&page=&utm_source=opensearch" },
		{ "netflix", "google-chrome-stable https://www.netflix.com/Kids" },
	}},
	{ "hotkeys", function() return false, hotkeys_popup.show_help end},
	{ "manual", config.terminal .. " -e man awesome" },
	{ "edit config", config.editor_cmd .. " " .. awesome.conffile },
	{ "restart", awesome.restart },
	{ "quit", function() awesome.quit() end}
}

M.mainmenu = awful.menu({ 
	items = { 
		{ "awesome", awesome_menuitems, beautiful.awesome_icon },
		{ "open terminal", config.terminal },
	}
})

M.mainmenu_launcher = awful.widget.launcher({ 
	image = beautiful.awesome_icon, 
	menu = M.mainmenu 
})

M.keyboard_layout = awful.widget.keyboardlayout()

--menubar.utils.terminal = .config.terminal -- Set the terminal for applications that require it

return M
