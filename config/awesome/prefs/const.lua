local awful = require("awful")

local terminal = "termite"
local editor = os.getenv("EDITOR") or "vim"

local M = {
	modkey = "Mod4",
	terminal = terminal,
	editor = editor,
	editor_cmd = terminal .. " -e " .. editor,
	preferred_layout = awful.layout.suit.corner.nw,
}

return M
