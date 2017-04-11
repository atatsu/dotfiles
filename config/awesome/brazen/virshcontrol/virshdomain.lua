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

local checkbox_props = {
	"border_width",
	"bg",
	"border_color",
	"check_border_color",
	"check_border_width",
	"check_color",
	"shape",
	"check_shape",
	"paddings",
	"color",
	"opacity",
}

function create_label_text (args)
	args = args or {}
	local markup
	if args.network then
		markup = brazenutils.markup{
			text = "[ network: " .. args.network .. " ]",
			small = true,
		}
		markup = brazenutils.markup{
			text = args.domain .. " " .. markup,
			color = args.color,
		}
		return markup
	end

	return brazenutils.markup{ text = args.domain, color = args.color }
end

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

	self._private.domain = conf.domain
	self._private.network = conf.network

	-- TODO: add hover effects to the checkbox and label
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
				--text = label.text,
				markup = create_label_text{ domain = conf.domain, network = conf.network, color = args.label_color },
				valign = "center",
				widget = wibox.widget.textbox,
			}
		}
	}

	local checkbox = self.widgets.checkbox
	for _, v in ipairs(checkbox_props) do
		if self._private.checkbox_props[v] ~= nil then
			checkbox["set_" .. v](checkbox, self._private.checkbox_props[v])
		end
	end

	checkbox:connect_signal("button::press", function ()
		local activate = not checkbox.checked
		if activate then
			self:emit_signal("domain::start", self)
			return
		end

		self:emit_signal("domain::destroy", self)
	end)

	return self
end

function VirshDomain:get_domain ()
	return self._private.domain
end

function VirshDomain:get_network ()
	return self._private.network
end

function VirshDomain:check ()
	local _ = self._private
	local checkbox = self.widgets.checkbox
	checkbox:set_checked(true)
	for i, v in ipairs(checkbox_props) do
		if _.checkbox_props_active[v] ~= nil then
			checkbox["set_" .. v](checkbox, _.checkbox_props_active[v])
		end
	end

	-- don't forget about the label!
	local markup = create_label_text{ domain = _.domain, network = _.network, color = _.label_color_active }
	self.widgets.domain_label_margin.domain_label:set_markup(markup)
end

function VirshDomain:uncheck ()
	local _ = self._private
	local checkbox = self.widgets.checkbox
	checkbox:set_checked(false)
	for i, v in ipairs(checkbox_props) do
		if _.checkbox_props[v] ~= nil then
			checkbox["set_" .. v](checkbox, _.checkbox_props[v])
		elseif _.checkbox_props_active[v] ~= nil then
			-- handle the use case where checked props are set, but no unchecked
			-- props are, in which case default styling is implicit, so we need
			-- to unset the changes we applied when the checkbox was checked
			checkbox["set_" .. v](checkbox, nil)
		end
	end

	-- restore label
	local markup = create_label_text{ domain = _.domain, network = _.network, color = _.label_color }
	self.widgets.domain_label_margin.domain_label:set_markup(markup)
end

return setmetatable(VirshDomain, {
	__call = function (cls, ...)
		return cls.new(...)
	end
})
