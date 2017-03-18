local awful = require("awful")
local beautiful = require("beautiful")
local common = require("awful.widget.common")
local util = require("awful.util")

local is_setup = false

local M = {
	init = function ()
		if is_setup then return end
	end
}

--- An `update_function` for `awful.widget.taglist`. 
-- Tags with glyph icons as names have a nice circular background shape.
-- Doesn't work so well when the tag name is actual text. So this here
-- function removes it for selected tags if their length is longer than one
-- and they aren't a glyph
-- I had initially tried implementing it via a tag signal (`property::selected`)
-- but unfortunately the signals... well I can't remember what was wrong now, 
-- specifically. But something to do with the signal handling timing removed
-- it as an option. 
function M.remove_shape_from_text_tags (w, buttons, label, data, objects)
	-- `w` in this context is just a layoutbox, as that's all the taglist
	-- really is
	common.list_update(w, buttons, label, data, objects)
	local t = awful.screen.focused().selected_tag

	-- leave the shape for any tag name one character in length, or
	-- if it's a glyph
	if t.name:len() < 2 or t.name:find("\xef") ~= nil then return end

	-- anything longer than one character has the shape removed and is
	-- instead foreground colored
	w.children[t.index].shape = nil
	w.children[t.index].bg = nil
	local font = beautiful.taglist_font or beautiful.font or ""
	for i, v in ipairs(w.children[t.index]:get_all_children()) do
		if v.markup or v.text then
			v.markup = "<span font_desc='" .. font .. "'><span color='" .. util.ensure_pango_color(beautiful.taglist_bg_focus) ..
				"'>" .. (util.escape(v.text) or "") .. "</span></span>"
		end
	end
end

return M
