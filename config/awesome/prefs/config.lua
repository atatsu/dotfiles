local awful = require("awful")

local utils = require("utils")
local iconutils = utils.icon

local terminal = "termite"
local editor = os.getenv("EDITOR") or "vim"

local M = {
	editor = editor,
	editor_cmd = terminal .. " -e " .. editor,
	modkey = "Mod4",
	preferred_layout = awful.layout.suit.corner.nw,
	terminal = terminal,
	--theme = awful.util.get_themes_dir() .. "xresources/theme.lua",
	focus_highlight_fade = 1,
	theme = awful.util.getdir("config") .. "/themes/oblivion/theme.lua",
	tags_for_screen = {
		[1] = { iconutils.dev, iconutils.games, iconutils.misc },
		[2] = { iconutils.devalt, iconutils.misc },
		[3] = { iconutils.misc },
	},
}

return M
