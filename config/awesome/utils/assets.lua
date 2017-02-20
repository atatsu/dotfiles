local gears = require("gears")
local shape = gears.shape
local surface = gears.surface
local share_assets = dofile("/usr/share/awesome/themes/xresources/assets.lua")

local M = {
	share = share_assets,
}

function tohex (rgb)
	-- thanks to https://gist.github.com/marceloCodget/3862929
	local chars = "0123456789ABCDEF"
	local htmlhex = "#"
	for _, v in ipairs(rgb) do
		local hex = ""

		while (v > 0) do
			local index = math.fmod(v, 16) + 1
			v = math.floor(v / 16)
			hex = string.sub(chars, index, index) .. hex
		end

		if string.len(hex) == 0 then
			hex = "00"
		elseif string.len(hex) == 1 then
			hex = "0" .. hex
		end

		htmlhex = htmlhex .. hex
	end

	return htmlhex
end

function M.lighten_up (color, amount)
	rgb = {}
	for s in color:gmatch("[a-fA-F0-9][a-fA-F0-9]") do
		rgb[#rgb+1] = tonumber("0x" .. s)
	end

	for i, v in ipairs(rgb) do
		new_val = rgb[i] + amount
		rgb[i] = new_val <= 255 and new_val or 255
	end

	return tohex(rgb, amount)
end

return M
