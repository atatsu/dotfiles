-- Internal widget used by VirshControl the display/control
-- of configured domains.
--
-- @author Nathan Lundquist (atatsu)
-- @copyright 2017 Nathan Lundquist
-- @classmod brazen.virshcontrol.domain
----------------------------------------------------------------------------
local path = (...):match("(.-)[^%.]+$")
local base = require("wibox.widget.base")
local gears = require("gears")
local util = require("awful.util")
local wibox = require("wibox")

local brazenutils = require("brazen.utils")
local commands = require(path .. "commands")

local truthy = brazenutils.truthy
local falsy = brazenutils.falsy
local markup = brazenutils.markup

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

function _get_network_markup (args, active)
	local network = args.network or ""
	if falsy(network) then return nil end

	local glyph = args.label_network_glyph or ""
	local combined = glyph .. network
	return markup{ text = combined, color = active and args.label_color_active or args.label_color }
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

	commands.init(self)

	local _p = self._private
	_p.domain = conf.domain
	_p.network = conf.network

	-- TODO: add hover effects to the checkbox and label
	self:setup{
		id = "widgets",
		widget = wibox.container.place,
		content_fill_horizontal = true,
		{
			layout = wibox.layout.flex.horizontal,
			{
				layout = wibox.layout.fixed.horizontal,
				{
					id = "checkbox",
					widget = wibox.widget.checkbox,
					checked = false,
					paddings = 2,
					shape = gears.shape.circle,
				},
				{
					widget = wibox.container.margin,
					left = 5,
					{
						id = "domain",
						widget = wibox.widget.textbox,
						align = "left",
						markup = markup{ text = _p.domain, color = _p.label_color },
						valign = "center",
					},
				}
			},
			{
				id = "network",
				widget = wibox.widget.textbox,
				align = "left",
				markup = _get_network_markup(_p),
				valign = "center",
			},
			{
				widget = wibox.container.place,
				fill_horizontal = true,
				halign = "right",
				{
					id = "destroy_confirm",
					align = "right",
					valign = "center",
					markup = markup{ text = _p.destroy_confirm_glyph, color = _p.label_color },
					visible = false,
					widget = wibox.widget.textbox,
				},
			}
		}
	}

	-- hide the network shit if there isn't actually a network configured
	if falsy(_p.network) then
		--self.widgets["network"]:set_visible(false)
	end

	-- make it so we can just key into our first level widget
	-- to query for any child, no matter how deeply nested
	setmetatable(self.widgets, {
		__index = function (table, key)
			local children = self:get_children_by_id(key)
			if #children > 0 then
				return children[1]
			end
		end
	})

	-- apply all custom checkbox properties 
	local checkbox = self.widgets.checkbox
	for _, v in ipairs(checkbox_props) do
		if _p.checkbox_props[v] ~= nil then
			checkbox["set_" .. v](checkbox, _p.checkbox_props[v])
		end
	end

	_connect_signals(self)

	commands[self].check_vm_status()
	return self
end

function VirshDomain:get_domain ()
	return self._private.domain
end

function VirshDomain:get_network ()
	return self._private.network
end

function VirshDomain:check ()
	local _p = self._private
	-- make sure we can restore our shit
	_p.restore = _restore_widgets_cb(self)

	_disconnect_hover_signals(self)

	local checkbox = self.widgets.checkbox
	checkbox:set_checked(true)
	for _, v in ipairs(checkbox_props) do
		if _p.checkbox_props_active[v] ~= nil then
			checkbox["set_" .. v](checkbox, _p.checkbox_props_active[v])
		end
	end

	-- don't forget about the label!
	--local _markup = markup{ text = _p.domain, color = _p.label_color_active }
	--self.widgets["domain"]:set_markup(_markup)
	--if truthy(_p.network) then
	--  _markup = markup{ text = _p.label_network_glyph .. _p.network, color = _p.label_color_active }
	--  self.widgets["network"]:set_markup(_markup)
	--end
end

function VirshDomain:start_network ()
	commands[self].start_network()
end

function VirshDomain:uncheck ()
	local _p = self._private

	local checkbox = self.widgets.checkbox
	checkbox:set_checked(false)

	if _p.restore then _p.restore() end
	_reconnect_hover_signals(self)
end

function VirshDomain:network_started ()
	local _p = self._private
	local _w = self.widgets
	local _markup = _get_network_markup(_p, true)
	_w.network:set_markup(_markup)
end

-- When changing properties of widgets we need to first collect
-- their current properties/settings in case their current
-- styling is based on defaults. If so, attempting to use the default
-- overrides provided by `VirshControl` won't have the desired effect 
-- as these properties won't be set, and we'll be left with whatever 
-- styling was applied from checking and/or hovering.
function _restore_widgets_cb (self)
	-- make sure no hover effects are captured for our restore
	self.widgets:emit_signal("mouse::leave")

	local _p = self._private

	local checkbox_restore_props = {}
	local checkbox = self.widgets["checkbox"]
	checkbox:emit_signal("mouse::leave")
	for _, v in ipairs(checkbox_props) do
		checkbox_restore_props[v] = checkbox["get_" .. v](checkbox)
	end

	local domain_restore_markup = self.widgets["domain"]:get_markup()
	local network_restore_markup
	if truthy(_p.network) then
		network_restore_markup = self.widgets["network"]:get_markup()
	end

	return function ()
		for _, v in ipairs(checkbox_props) do
			checkbox["set_" .. v](checkbox, checkbox_restore_props[v])
		end
		self.widgets["domain"]:set_markup(domain_restore_markup)
		if truthy(_p.network) then
			self.widgets["network"]:set_markup(network_restore_markup)
		end
	end
end

function _connect_signals (self)
	local _p = self._private
	if not _p.signals then _p.signals = {} end
	local checkbox = self.widgets.checkbox

	if not _p.signals.mouse_enter then
		-- {{{ Signal handler for mouse::enter emits
		function _p.signals.mouse_enter ()
			-- capture our restore settings before applying any hover effects
			_p.restore = _restore_widgets_cb(self)

			for _, v in ipairs(checkbox_props) do
				if _p.checkbox_props_hover[v] ~= nil then
					checkbox["set_" .. v](checkbox, _p.checkbox_props_hover[v])
				end
			end
			local _markup = markup{ text = _p.domain, color = _p.label_color_hover }
			self.widgets["domain"]:set_markup(_markup)
			if truthy(_p.network) then
				_markup = markup{ text = _p.label_network_glyph .. _p.network, color = _p.label_color_hover }
				self.widgets["network"]:set_markup(_markup)
			end
		end
		-- }}}
	end

	if not _p.signals.mouse_leave then
		-- {{{ Signal handler for mouse::leave emits
		function _p.signals.mouse_leave ()
			if _p.restore then _p.restore() end
		end
		-- }}}
	end

	if not _p.signals.button_press then
		-- {{{ Signal handler for button::press emits
		function _p.signals.button_press (w, lx, ly, button)
			-- only respond to left-clicks
			if button ~= 1 then return end

			local activate = not checkbox.checked
			if activate then
				self:emit_signal("domain::start", self)
				return
			end

			_confirm_destroy(self)
			--self:emit_signal("domain::destroy", self)
		end
		-- }}}
	end

	if truthy(_p.checkbox_props_hover) or truthy(_p.label_color_hover) then
		self.widgets:connect_signal("mouse::enter", _p.signals.mouse_enter)
		self.widgets:connect_signal("mouse::leave", _p.signals.mouse_leave)
	end

	self.widgets:connect_signal("button::press", _p.signals.button_press)
end

function _disconnect_click_signals (self)
	local _p = self._private
	self.widgets:disconnect_signal("button::press", _p.signals.button_press)
end

function _reconnect_click_signals (self)
	local _p = self._private
	self.widgets:connect_signal("button::press", _p.signals.button_press)
end

function _disconnect_hover_signals (self)
	local _p = self._private
	self.widgets:disconnect_signal("mouse::enter", _p.signals.mouse_enter)
	self.widgets:disconnect_signal("mouse::leave", _p.signals.mouse_leave)
end

function _reconnect_hover_signals (self)
	local _p = self._private
	self.widgets:connect_signal("mouse::enter", _p.signals.mouse_enter)
	self.widgets:connect_signal("mouse::leave", _p.signals.mouse_leave)
end

-- After having attempted to uncheck a domain to shut it down this handler
-- will display a power off glyph on the far right of the domain list row.
-- An actual destroy won't be issued unless this power off glyph is clicked.
-- But, what if you accidentally "unchecked" the domain? Now you have this 
-- power off glyph eye sore present. No worries! It'll fade in style 
-- over a configurable number of seconds.
function _confirm_destroy (self)
	local _p = self._private
	local _w = self.widgets
	-- Display the destroy confirm widget and set a timer on it,
	-- if no action taken within X seconds rehide widget and
	-- leave active widgets in active state.
	-- Also disable the click event so it can't be spammed.
	_disconnect_click_signals(self)
	self.widgets["destroy_confirm"]:set_visible(true)

	-- Show in full for 1 whole second, then use the rest of the configured
	-- time to fade out. Sanitize that shit first.
	local destroy_confirm_timeout = _p.destroy_confirm_timeout > 0 and math.ceil(_p.destroy_confirm_timeout) or 1
	--local fade_increment = (1 / (destroy_confirm_timeout - 1 > 0 and destroy_confirm_timeout - 1 or 1)) * .01
	local fade_increment = (1 / ((destroy_confirm_timeout - 1 > 0 and destroy_confirm_timeout - 1 or 1) * 1000))
	local timer
	local destroy_confirmed_check
	destroy_confirmed_check = function (confirmed)
		if timer and timer.started then timer:stop() end
		-- We know at this point that even if this is the first go around we've elapsed
		-- at least a second, so go ahead and start fading, but first speed up our timer.
		-- Fire every millisecond.
		if timer then timer.timeout = .001 end
		local opacity = _w.destroy_confirm:get_opacity()
		_w.destroy_confirm:set_opacity(opacity - fade_increment)
		_w:emit_signal("widget::redraw_needed")

		-- If our opacity is at 0 it's time to end this charade
		if _w.destroy_confirm:get_opacity() <= 0 then
			-- cleanup
			_w.destroy_confirm:set_visible(false)
			-- restore opacity for next time
			_w.destroy_confirm:set_opacity(1)
			_w:disconnect_signal("button::press", destroy_confirmed_check)
			_reconnect_click_signals(self)
			timer = nil
		end

		if confirmed then
			_w.destroy_confirm:set_visible(false)
			_w.destroy_confirm:set_opacity(1)
			_reconnect_click_signals(self)
			self:emit_signal("domain::destroy", self)
			return
		end

		-- again?
		if timer then timer:again() end
	end

	self.widgets["destroy_confirm"]:connect_signal("button::press", function () destroy_confirmed_check(true) end)

	timer = gears.timer{ 
		timeout = 1,
		autostart = true, 
		callback = function () destroy_confirmed_check(false) end,
	}
end

return setmetatable(VirshDomain, {
	__call = function (cls, ...)
		return cls.new(...)
	end
})
