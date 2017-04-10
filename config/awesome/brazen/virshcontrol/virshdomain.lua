-- Internal widget used by VirshControl the display/control
-- of configured domains.
--
-- @author Nathan Lundquist (atatsu)
-- @copyright 2017 Nathan Lundquist
-- @classmod brazen.virshcontrol.domain
----------------------------------------------------------------------------
local base = require("wibox.widget.base")
local gears = require("gears")
local util = require("awful.util")
local wibox = require("wibox")

local brazenutils = require("brazen.utils")

local VirshDomain = {}
VirshDomain.__index = VirshDomain

function VirshDomain.new (conf, args)
	conf = conf or {}
	if not conf.domain then 
		brazenutils.notify_normal("VirshControl misconfiguration", "passed config missing domain name")
	end

	args = args or {}
	local w = base.make_widget(nil, nil, { enable_properties = true })
	util.table.crush(w._private, args)
	
	local widget = wibox.layout.fixed.horizontal()
	util.table.crush(w, widget, false)

	local self = setmetatable(w, VirshDomain)
	util.table.crush(self._private, args)

	self:setup{
		id = "widgets",
		layout = wibox.layout.fixed.horizontal,
		{
			id = "checkbox",
			checked = false,
			paddings = 2,
			shape = gears.shape.circle,
			widget = wibox.widget.checkbox,
		},
		{
			id = "domain_label_margin",
			widget = wibox.container.margin,
			left = 5,
			{
				id = "domain_label",
				align = "center",
				text = "hi",
				valign = "center",
				widget = wibox.widget.textbox,
			}
		}
	}
	local checkbox = self.widgets.checkbox

	return self
end

return setmetatable(VirshDomain, {
	__call = function (cls, ...)
		return cls.new(...)
	end
})
