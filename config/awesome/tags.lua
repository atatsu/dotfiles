--[[
        
--]]
local M = {}

local friendly = {
	["chat"] = "",
	["steam"] = "",
	["web"] = "",
	["dev"] = "",
	["games"] = "",
	["music"] = "",
	["devalt"] = "",
	["misc"] = "",
}

M.friendly_names = friendly

M[1] = { friendly.web, friendly.dev, friendly.games, friendly.misc }
M[2] = { friendly.chat, friendly.music, friendly.misc }
M[3] = { friendly.devalt, friendly.misc }

return M
