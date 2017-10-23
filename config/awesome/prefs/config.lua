local awful = require("awful")

local utils = require("utils")
local icons = require("prefs.icons")

local terminal = "termite"
local editor = os.getenv("EDITOR") or "vim"

local M = {
	editor = editor,
	editor_cmd = terminal .. " -e " .. editor,
	modkey = "Mod4",
	--preferred_layout = awful.layout.suit.tile.left,
	preferred_layout = awful.layout.suit.tile.floating,
	terminal = terminal,
	--theme = awful.util.get_themes_dir() .. "xresources/theme.lua",
	focus_highlight_fade = 1,
	theme = awful.util.getdir("config") .. "themes/oblivion/theme.lua",
	tags_for_screen = {
		[1] = { icons.dev, icons.games, icons.misc },
		[2] = { icons.devalt, icons.misc },
		[3] = { icons.misc },
	},
}

return M
