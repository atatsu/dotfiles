----------------------------------------------------------------------------
-- A widget for starting/stopping virtual machines via virsh.
--
-- @usage
-- wibox.widget {
--	widget = widgets.virshcontrol
-- }
--
-- @author Nathan Lundquist (atatsu)
-- @copyright 2017 Nathan Lundquist
-- @classmod widgets.virshcontrol
----------------------------------------------------------------------------
local awful = require("awful")
local base = require("wibox.widget.base")
local beautiful = require("beautiful")
local gears = require("gears")
local util = require("awful.util")
local wibox = require("wibox")

local widgetutil = require("widgets.util")
local helperutils = require("utils.helper")

local function notify (message)
	helperutils.notify_normal("VirshControl", message)
end

local function notifyerr (message)
	helperutils.notify_error("VirshControl", message)
end

local function easy_async (cmd, cb)
	awful.spawn.easy_async(cmd, function (stdout, stderr, reason, code)
		if stderr and stderr ~= "" then
			print(stderr)
		end
		cb({ stdout = stdout, stderr = stderr, reason = reason, code = code })
	end)
end

local VirshControl = {}
VirshControl.__index = VirshControl

local properties 
properties = {
	checkbox_props = beautiful.virshcontrol_checkbox_props or {},

	icon_glyph = beautiful.virshcontrol_icon_glyph or "vc",
	icon_color_normal = beautiful.virshcontrol_icon_color_normal or beautiful.fg_normal or "#ff0000",
	icon_color_active = beautiful.virshcontrol_icon_color_active or beautiful.fg_urgent or "#ff0000",
	icon_margins = beautiful.virshcontrol_icon_margins or { left = 1, right = 1 },

	notification_accent_color = beautiful.virshcontrol_notification_accent_color or beautiful.taglist_bg_focus or "#ff0000",

	row_height = beautiful.virshcontrol_row_height or 24,
	-- left, right, top, bottom
	row_margins = beautiful.virshcontrol_row_margins or 5,
}

-- Create the accessors
for prop in pairs(properties) do
	VirshControl["set_" .. prop] = function (self, value)
		local changed = self._private[prop] ~= value
		self._private[prop] = value

		if changed then
			self:emit_signal("property::" .. prop)
			self:emit_signal("widget::redraw_needed")
		end
	end

	VirshControl["get_" .. prop] = function (self)
		return self._private[prop] == nil and properties[prop] or self._private[prop]
	end
end

-- {{{ Helpers that I didn't want to pollute the instance with.
--     Think of them as honorary private members.
local _helpers
_helpers = (function ()

	-- {{{ Collection of signal handler callbacks
	function init_signal_handlers (self)
		if _helpers.signal_handlers then
			return _helpers.signal_handlers
		end

		return {
			checkbox_pressed = function (checkbox)
				local activate = not checkbox.checked
				if activate then
					_helpers.commands.start_vm(checkbox)
					return
				end

				print("Not Implemented")
				--_helpers.commands.stop_vm(checkbox)
				--checkbox.checked = false
			end
		}
	end
	-- }}}

	-- {{{ Collection of commands that get executed through the shell
	function init_commands (self)
		if _helpers.commands then
			return _helpers.commands
		end

		return {
			-- Ran when the widget is first being initialized to ensure that its
			-- display is accurate (domains checked if running)
			check_vm_status = function (checkbox)
				_helpers.commands.start_vm(checkbox, true)
			end,

			start_vm = function (checkbox, status_check)
				local domain, network = checkbox._domain, checkbox._network
				local status
				if status_check then
					status = { is_running = false, was_checked = false }
				else
					status = { 
						network = { started = false, failed = false },
						domain = { started = false, failed = false }
					}
				end

				-- first check if we need to attempt to startup a network
				if network and not status_check then
					_helpers.commands._start_network(network, status)
				else
					if not status_check then
						status.network.started = true
					end
				end

				_helpers.commands._start_domain(domain, status)

				local timer
				timer = gears.timer{
					timeout = 1,
					autostart = true,
					callback = function ()
						local status_check = status.was_checked ~= nil

						if status_check then
							if status.was_checked and status.is_running then
								timer:stop()
								checkbox.checked = true
								_helpers.mutators.activate_icon(self)
								return
							elseif status.was_checked and not status.is_running then
								timer:stop()
								return
							end

							return
						end

						if status.network.started and status.domain.started then
							timer:stop()
							if status.network.failed or status.domain.failed then
								return
							end
							checkbox.checked = true
							_helpers.mutators.activate_icon(self)
						end
					end
				}

			end,

			_start_network = function (network, status)
				local markup
				easy_async("bash -c 'virsh net-list | grep " .. network .. "'", function (result)
					if result.code == 0 then
						markup = widgetutil.markup(network, self:get_notification_accent_color())
						notify("network <b>" .. markup .. "</b> is already running")
						status.network.started = true
					else
						easy_async("bash -c 'virsh net-start " .. network .. "'", function (result)
							if result.code == 0 then
								markup = widgetutil.markup(network, self:get_notification_accent_color())
								notify("network <b>" .. markup .. "</b> started")
								status.network.started = true
							else
								notifyerr(stderr)
								status.network.started = true
								status.network.failed = true
							end
						end)
					end
				end)
			end,

			_start_domain = function (domain, status)
				local markup
				easy_async("bash -c 'virsh list | grep " .. domain .. "'", function (result)
					if result.code == 0 then
						if status.was_checked == nil then
							markup = widgetutil.markup(domain, self:get_notification_accent_color())
							notify("domain <b>" .. markup .. "</b> is already running")
							status.domain.started = true
						else
							status.was_checked = true
							status.is_running = true
						end
					else
						if status.was_checked ~= nil then
							status.was_checked = true
							return
						end

						easy_async("bash -c 'virsh start " .. domain .. "'", function (result)
							if result.code == 0 then
								markup = widgetutil.markup(domain, self:get_notification_accent_color())
								notify("domain <b>" .. markup .. "</b> started")
								status.domain.started = true
							else
								notifyerr(stderr)
								status.domain.started = true
								status.domain.failed = true
							end
						end)
					end
				end)
			end,

			stop_vm = function (checkbox)
			end
		}
	end
	-- }}}

	-- {{{ Collection of functions used for calculating measurements for various widgets/components
	function init_calculate (self)
		if _helpers.calculate then
			return _helpers.calculate
		end

		 return {
			-- Calculates height for the main wibox based on the number of 
			-- rows needed and the configured row height. Broken out into 
			-- its own standalone function mainly so VirshControl:toggle_domain_list 
			-- wasn't so bulky... even though its still pretty bulky.
			wibox_height = function ()
				local row_height = self:get_row_height()
				local row_margins = self:get_row_margins()
				local base_height = row_height * #self._private.virsh_config

				local top, bottom
				if type(row_margins) == "table" then
					top, bottom = row_margins.top or 0, row_margins.bottom or 0
				else
					top, bottom = row_margins, row_margins
				end

				local margin_adjustment = top * #self._private.virsh_config + bottom * #self._private.virsh_config
				return base_height + margin_adjustment
			end,

			-- Calculates the margins for a given row and ensures that no double 
			-- padding shit takes place. You know, when you say an item has margins of 4, 
			-- the first item has clean 4 on top, the last item has a clean 4 on bottom,
			-- and everything in between has 8 due to the items' bottom and top margins
			-- combininig.
			harmonious_margins = function (current_row_idx)
				local margins = self:get_row_margins()
				local num_rows = #self._private.virsh_config

				local left, right, top, bottom
				if type(margins) == "table" then
					left, right, top, bottom = margins.left, margins.right, margins.top, margins.bottom
				else
					left, right, top, bottom = margins, margins, margins, margins
				end

				if current_row_idx == 1 then
					bottom = bottom / 2
				elseif current_row_idx ~= num_rows then
					bottom = bottom / 2
					top = top / 2
				else
					top = top / 2
				end

				return left, right, top, bottom
			end
		}
	end
	-- }}}

	-- {{{ Collection of functions used for changing the looks of the various widgets/components
	function init_mutators (self)
		if _helpers.mutators then
			return _helpers.mutators
		end

		return {
			activate_icon = function (self)
				local icon = self.row.margin.icon
				markup = widgetutil.markup(self:get_icon_glyph(), self:get_icon_color_active())
				icon:set_markup(markup)
			end,

			setup_domain_list = function (self)
				local instance = wibox{
					height = _helpers.calculate.wibox_height(),
					width = 150,
					ontop = true,
					visible = false,
				}
				instance:setup{
					id = "outer",
					widget = wibox.layout.flex.vertical,
				}

				local checkbox_props = self:get_checkbox_props()
				for i, v in ipairs(self._private.virsh_config) do
					local row = wibox.layout.fixed.horizontal()
					local checkbox = wibox.widget{
						checked = false,
						paddings = 2,
						shape = gears.shape.circle,
						widget = wibox.widget.checkbox,
						-- theme
						border_color = checkbox_props.border_color,
						check_color = checkbox_props.check_color,
					}
					checkbox:connect_signal("button::press", _helpers.signal_handlers.checkbox_pressed)
					checkbox._domain = v.domain
					checkbox._network = v.network
					checkbox._monitor = v.monitor
					row:add(checkbox)

					_helpers.commands.check_vm_status(checkbox)

					local label = wibox.widget{
						align = "center",
						text = v.domain or "MISCONFIGURED",
						widget = wibox.widget.textbox,
						valign = "center",
					}
					label:connect_signal("button::press", function () _helpers.signal_handlers.checkbox_pressed(checkbox) end)
					row:add(wibox.container.margin(label, 5))

					local left, right, top, bottom = _helpers.calculate.harmonious_margins(i)
					instance.outer:add(wibox.container.margin(row, left, right, top, bottom))
				end

				-- position the wibox
				-- TODO: place near mouse rather than corner
				awful.placement.top_right(instance)
				awful.placement.no_offscreen(instance)
				instance:connect_signal("mouse::leave", function () self:toggle_domain_list() end)
				self._domain_list = instance
			end
		}
	end
	-- }}}

	return {
		signal_handlers = nil,
		commands = nil,
		calculate = nil,
		init = function (self)
			_helpers.signal_handlers = init_signal_handlers(self)
			_helpers.commands = init_commands(self)
			_helpers.calculate = init_calculate(self)
			_helpers.mutators = init_mutators(self)
		end
	}
end)()

-- }}}


--- Create a new virsch control widget.
-- @treturn VirshControl A new VirshControl instance.
function VirshControl.new (args)
	local virsh_config = args.virsh_config or {}
	args.virsh_config = nil

	local w = base.make_widget(nil, nil, { enable_properties = true })
	util.table.crush(w._private, args or {})

	local widget = wibox.layout.fixed.horizontal()
	util.table.crush(w, widget, false)

	local self = setmetatable(w, VirshControl)
	util.table.crush(self._private, args or {})
	self._private.virsh_config = virsh_config

	-- initialize all the helper shit that isn't attached to our instance
	-- but needs to be able to access members on the instance
	_helpers.init(self)

	local margins = self:get_icon_margins() or {}
	self:setup{
		id = "row",
		layout = wibox.layout.fixed.horizontal,
		{
			id = "margin",
			layout = wibox.container.margin,
			left = margins.left or 0,
			right = margins.right or 0,
			{
				id = "icon",
				align = "center",
				--text = self:get_icon_glyph(),
				markup = widgetutil.markup(self:get_icon_glyph(), self:get_icon_color_normal()),
				valign = "center",
				widget = wibox.widget.textbox
			}
		}
	}

	local icon = self.row.margin.icon
	icon:buttons(awful.util.table.join(
		-- left-click
		awful.button({ }, 1, function ()
			self:toggle_domain_list()
		end)
	))

	_helpers.mutators.setup_domain_list(self)
	return self
end

function VirshControl:toggle_domain_list ()
	if not self._domain_list then
		_helpers.mutators.setup_domain_list(self)
	end

	self._domain_list.visible = not self._domain_list.visible
end

return setmetatable(VirshControl, {
	__call = function (cls, ...)
		return cls.new(...)
	end
})
