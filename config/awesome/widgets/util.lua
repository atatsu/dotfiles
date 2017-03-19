local M = {}

function M.markup (text, color)
	if color == nil then return text end
	return "<span foreground=\"" .. color .. "\">" .. text .. "</span>"
end

return M
