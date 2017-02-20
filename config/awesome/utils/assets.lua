local beautiful = require("beautiful")
local cairo = require("lgi").cairo
local gears = require("gears")
local shape = gears.shape
local surface = gears.surface
local share_assets = dofile("/usr/share/awesome/themes/xresources/assets.lua")

local M = {
	share = share_assets,
}

function M.taglist_shape (w, h)
	--[[
	return function (cr, width, height)
		print('yes?' .. 'w: ' .. w .. ' h: ' .. h)
		return surface.load_from_shape(w, h, shape.powerline, beautiful.taglist_bg_focus)
	end
	--]]
	return function (cr, width, height)
		print('width: ' .. width .. ' height: ' .. height)
		--local img = cairo.ImageSurface(cairo.Format.ARGB32, w, h)
		--local cr = cairo.Context(img)
		--cr:set_source(gears.color(beautiful.taglist_bg_focus))
		--local t = shape.powerline(cr, w, h)
		--cr:paint()
		--return t
		return shape.powerline(cr, w, h, 5)
	end
end

return M
