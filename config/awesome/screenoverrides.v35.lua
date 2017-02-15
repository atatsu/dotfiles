local M = {}

if screen.count() == 3 then
	M[1] = screen["DVI-I-1"].index
	M[2] = screen["DVI-D-0"].index
	M[3] = screen["HDMI-0"].index
end

return M
