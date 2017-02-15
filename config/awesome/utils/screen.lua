local M = {}
-- The order in which displays are handled by `xrandr` determines their index!
-- $ xrandr 
--   --output DVI-I-1 --primary --auto                         -- screen 1, or screen.primary
--   --output DVI-D-0 --auto --right-of DVI-I-1 --rotate left  -- screen 2
--   --output HDMI-0 --auto --left-of DVI-I-                   -- screen 3

local screen_cache = {}
local screen_count = screen:count()

function M.get_by_index (index)
	index = index or 1

	if screen_count ~= screen:count() then
		screen_cache = {}
	end

	local found = screen_cache[index]
	if found then
		return found
	end

	for s in screen do
		if s.index == index then
			screen_cache[s.index] = s
			return s
		end
	end
end

return M
