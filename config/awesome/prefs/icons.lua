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
	end
}

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
M.ontop = ""
M.steam = ""
M.sticky = ""
M.tux = ""
M.video = ""
M.volume = ""
M.volumeoff = ""
M.web = ""

return M
