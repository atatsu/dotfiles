local awful = require("awful")

local terminal = "termite"
local editor = os.getenv("EDITOR") or "vim"

local M = {
	editor = editor,
	editor_cmd = terminal .. " -e " .. editor,
	modkey = "Mod4",
	preferred_layout = awful.layout.suit.corner.nw,
	terminal = terminal,
	theme = awful.util.get_themes_dir() .. "zenburn/theme.lua",
	--theme = awful.util.getdir("config") .. "/themes/gruvbox/theme.lua",
}

return M
