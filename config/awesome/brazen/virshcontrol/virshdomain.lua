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
local truthy = brazenutils.truthy

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
	local label_network_text = args.label_network_text or ""
	local network = args.network or ""
	local domain = args.domain or ""
	local markup

	if network then
		markup = brazenutils.markup{
			text = "[ " .. label_network_text .. network .. " ]",
			small = true,
		}
		markup = brazenutils.markup{
			text = domain .. " " .. markup,
			color = args.color,
		}
		return markup
	end

	return brazenutils.markup{ text = domain, color = args.color }
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

	local _p = self._private
	_p.domain = conf.domain
	_p.network = conf.network

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
				markup = create_label_text{ 
					domain = _p.domain, network = _p.network, color = _p.label_color, label_network_text = _p.label_network_text,
				},
				valign = "center",
				widget = wibox.widget.textbox,
			}
		}
	}

	-- apply all custom checkbox properties 
	local checkbox = self.widgets.checkbox
	for _, v in ipairs(checkbox_props) do
		if _p.checkbox_props[v] ~= nil then
			checkbox["set_" .. v](checkbox, _p.checkbox_props[v])
		end
	end

	connect_signals(self)

	return self
end

function VirshDomain:get_domain ()
	return self._private.domain
end

function VirshDomain:get_network ()
	return self._private.network
end

function VirshDomain:check ()
	disconnect_signals(self)
	local _p = self._private
	local checkbox = self.widgets.checkbox
	checkbox:set_checked(true)
	for _, v in ipairs(checkbox_props) do
		if _p.checkbox_props_active[v] ~= nil then
			checkbox["set_" .. v](checkbox, _p.checkbox_props_active[v])
		end
	end

	-- don't forget about the label!
	local markup = create_label_text{ 
		domain = _p.domain, network = _p.network, color = _p.label_color_active, label_network_text = _p.label_network_text
	}
	self.widgets.domain_label_margin.domain_label:set_markup(markup)
end

function VirshDomain:uncheck ()
	local _p = self._private
	local checkbox = self.widgets.checkbox
	checkbox:set_checked(false)
	for _, v in ipairs(checkbox_props) do
		if _p.checkbox_props[v] ~= nil then
			checkbox["set_" .. v](checkbox, _p.checkbox_props[v])
		elseif _p.checkbox_props_active[v] ~= nil then
			-- handle the use case where checked props are set, but no unchecked
			-- props are, in which case default styling is implicit, so we need
			-- to unset the changes we applied when the checkbox was checked
			checkbox["set_" .. v](checkbox, nil)
		end
	end

	-- restore label
	local markup = create_label_text{ 
		domain = _p.domain, network = _p.network, color = _p.label_color, label_network_text = _p.label_network_text
	}
	self.widgets.domain_label_margin.domain_label:set_markup(markup)
end

function connect_signals (self)
	local _p = self._private
	if not _p.signals then _p.signals = {} end
	local restore_props
	local restore_markup
	local checkbox = self.widgets.checkbox

	if not _p.mouse_enter then
		function _p.mouse_enter ()
			for _, v in ipairs(checkbox_props) do
				if _p.checkbox_props_hover[v] ~= nil then
					checkbox["set_" .. v](checkbox, _p.checkbox_props_hover[v])
				end
			end
			local markup = create_label_text{
				domain = _p.domain, network = _p.network, color = _p.label_color_hover, label_network_text = _p.label_network_text
			}
			self.widgets.domain_label_margin.domain_label:set_markup(markup)
		end
	end

	if not _p.mouse_leave then
		function _p.mouse_leave ()
			for _, v in ipairs(checkbox_props) do
				checkbox["set_" .. v](checkbox, restore_props[v])
			end
			local markup = create_label_text{
				domain = _p.domain, network = _p.network, color = _p.label_color, label_network_text = _p.label_network_text
			}
			self.widgets.domain_label_margin.domain_label:set_markup(restore_markup)
		end
	end

	if not _p.signals.button_press then
		function _p.button_press ()
			local activate = not checkbox.checked
			if activate then
				self:emit_signal("domain::start", self)
				return
			end

			self:emit_signal("domain::destroy", self)
		end
	end

	if truthy(_p.checkbox_props_hover) or truthy(_p.label_color_hover) then
		restore_props = {}
		restore_markup = self.widgets.domain_label_margin.domain_label:get_markup()
		for _, v in ipairs(checkbox_props) do
			restore_props[v] = checkbox["get_" .. v](checkbox)
		end

		self.widgets:connect_signal("mouse::enter", _p.mouse_enter)
		self.widgets:connect_signal("mouse::leave", _p.mouse_leave)
		_p.signals.mouse_enter = mouse_enter
		_p.signals.mouse_leave = mouse_leave
	end

	self.widgets:connect_signal("button::press", _p.button_press)
end

function disconnect_signals (self)
	local _p = self._private

	self.widgets:disconnect_signal("mouse::enter", _p.mouse_enter)
	self.widgets:disconnect_signal("mouse::leave", _p.mouse_leave)
	self.widgets:disconnect_signal("button::press", _p.button_press)
end

return setmetatable(VirshDomain, {
	__call = function (cls, ...)
		return cls.new(...)
	end
})
