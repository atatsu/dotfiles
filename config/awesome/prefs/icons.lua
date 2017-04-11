local glyphs = require("assets.glyphs")
-- Everything here was chosen based on font awesome
--
--[[
                                 
--]]

local is_setup = false

local M
M = {
	init = function ()
		if is_setup then return end
		is_setup = true
		for i, v in ipairs(glyphs) do
			M[i] = v
		end
	end
}

M.add = ""
M.chat = ""
M.clock = ""
M.close = ""
M.dev = ""
M.devalt = ""
M.eyeclosed = ""
M.eyeopen = ""
M.floating = ""
M.games = ""
M.maximized = ""
M.minimized = ""
M.misc = ""
M.music = ""
M.network = ""
M.ontop = ""
M.power = ""
M.steam = ""
M.sticky = ""
M.tux = ""
M.video = ""
M.virt_manager = ""
M.volume = ""
M.volumeoff = ""
M.web = ""

return M
