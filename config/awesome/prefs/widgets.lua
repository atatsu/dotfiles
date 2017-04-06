local awful = require("awful")
local beautiful = require("beautiful")
local hotkeys_popup = require("awful.hotkeys_popup").widget
--local menubar = require("menubar")

local config = require("prefs.config")
local icons = require("prefs.icons")
local utils = require("utils")
local widgets = require("widgets")

local is_setup = false
local widget_cache = {}

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

M.termleaf = utils.leaf("termite")

M.keyboard_layout = awful.widget.keyboardlayout()

function M.virshcontrol ()
	if widget_cache.virshcontrol then
		return widget_cache.virshcontrol
	end

	widget_cache.virshcontrol = widgets.virshcontrol{
		icon_glyph = icons.virt_manager, 
		icon_color_normal = beautiful.widget_icon_color,
		icon_margins = {
			left = 2,
			right = 5,
		},
		virsh_config = {
			{
				network = "default",
				domain = "gaming",
				monitor = 17,
			},
		}
	}
	return widget_cache.virshcontrol
end

--menubar.utils.terminal = .config.terminal -- Set the terminal for applications that require it

return M
