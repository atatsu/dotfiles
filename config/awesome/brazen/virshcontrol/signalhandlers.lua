local brazenutils = require("brazen.utils")

local markup = brazenutils.markup
local falsy = brazenutils.falsy
local truthy = brazenutils.truthy

local function notify (message)
	brazenutils.notify_normal("VirshControl", message)
end

local function notifyerr (message)
	brazenutils.notify_error("VirshControl", message)
end

local M = {}

function M.connect_own (virshcontrol)
	local signal_handlers = {
		-- fired whenever a domain is started or destroyed
		["domain::count::changed"] = {
			function (vc, count)
				-- if count is positive activate our icon, if count is 0
				-- deactivate our icon
				if count == 0 then
					vc:deactivate_icon()
					return
				end

				vc:activate_icon()
			end,
		},
	}

	for signal, handlers in pairs(signal_handlers) do
		for _, handler in ipairs(handlers) do
			virshcontrol:connect_signal(signal, handler)
		end
	end
end

function M.connect_domain (virshcontrol, domain)
	local domain_signal_handlers = {
		-- fired when an already started domain item is clicked, signifying the user
		-- wishes to power down the domain and/or its network
		["domain::action::destroy"] = {
			function (domain)
				print("stopping domain " .. domain:get_domain())
				domain:uncheck()
			end,
		},
		["domain::status::error"] = {
			function (domain, err)
				notifyerr(domain:get_domain() .. ": " .. err)
			end,
		},
		-- fired when a domain status check finds that the domain is already
		-- running
		["domain::status::running"] = {
			function (domain)
				domain:check()
				domain:update_domain_started()
				print("domain " .. domain:get_domain() .. " is running")
				local msg = "domain " .. markup{ text = domain:get_domain(), color = virshcontrol:get_notification_accent_color() } ..
					" is running"
				notify(msg)
				-- instruct virshdomain to watch for shutdown
				domain:command_monitor()
			end,
		},
		-- fired when an actual domain item is clicked, signifying the user wishes
		-- to fire up the domain and its network (if any)
		["domain::action::start"] = {
			function (domain)
				print("starting domain " .. domain:get_domain())
				domain:command_start_network()
			end,
		},
		-- fired when the domain has been started after a user has clicked
		-- a domain item, will occur after a `network::started` if configuration
		-- contains network details
		["domain::status::started"] = {
			function (domain)
				if falsy(domain:get_network()) then
					-- we didn't actually have a network start (as there isn't one)
					-- which means we aren't checked yet, so do it
					domain:check()
				end

				domain:update_domain_started()
				print("domain " .. domain:get_domain() .. " started")
				local msg = "domain " .. markup{ text = domain:get_domain(), color = virshcontrol:get_notification_accent_color() }
					.. " started"
				notify(msg)
				domain:command_monitor()
			end,
		},
		-- something went wrong while attempting to get the pid
		-- for the running domain
		["monitor::pid::error"] = {
			function (domain)
				print("unable to obtain pid for " .. domain:get_domain() .. ", monitor not active")
				local _markup = markup{ text = domain:get_domain(), color = virshcontrol:get_notification_accent_color() }
				notify("unable to obtain pid for " .. _markup .. ", monitor not active")
			end,
		},
		-- fired when the domain monitor has started
		["monitor::status::active"] = {
			function (domain, pid)
				local _markup = markup{ text = domain:get_domain(), color = virshcontrol:get_notification_accent_color() }
				notify("monitoring " .. _markup .. " [" .. pid .. "] for shutdown")

				virshcontrol:add_active_domain(domain)
			end,
		},
		-- something went wrong while the monitor was active
		["monitor::status::error"] = {
			function (domain, err)
				local _markup = markup{ text = domain:get_domain(), color = virshcontrol:get_notification_accent_color() }
				notifyerr("monitor (" .. _markup .. ") error: " .. err)
			end,
		},
		-- monitor ended, domain has shut down
		["monitor::status::exit"] = {
			function (domain)
				local _markup = markup{ text = domain:get_domain(), color = virshcontrol:get_notification_accent_color() }
				notify(_markup .. " domain has shut down")

				domain:update_domain_stopped()
				domain:command_destroy_network()
			end,
		},
		["network::status::destroyed"] = {
			function (domain)
				if truthy(domain:get_network()) then
					local _markup = markup{ text = domain:get_network(), color = virshcontrol:get_notification_accent_color() }
					notify("network " .. _markup .. " destroyed")
				end
				domain:update_network_stopped()
				domain:uncheck()
				virshcontrol:remove_active_domain(domain)
			end,
		},
		-- something went wrong while trying to start the network
		["network::status::error"] = {
			function (domain, err)
				notifyerr(domain:get_network() .. ": " .. err)
			end,
		},
		-- fired when a domain status check finds that a domain's network is already
		-- running
		["network::status::running"] = {
			function (domain)
				domain:check()
				domain:update_network_started()
				print("network " .. domain:get_network() .. " is running")
				local msg = "network " .. markup{ text = domain:get_network(), color = virshcontrol:get_notification_accent_color() } ..
					" is running"
				notify(msg)
			end,
		},
		-- fired when the network has been started after a user has clicked 
		-- a domain item, notifies status and instructs the domain
		-- to update its related widgets to reflect network status
		["network::status::started"] = {
			function (domain)
				-- we don't always actually have a network configured when this signal fires
				-- so check first to ensure we aren't notifying about a started network
				-- when we didn't actually start it
				if falsy(domain:get_network()) then
					return
				end
				domain:check()
				domain:update_network_started()
				print("network " .. domain:get_network() .. " started")
				local msg = "network " .. markup{ text = domain:get_network(), color = virshcontrol:get_notification_accent_color() } ..
					" started"
				notify(msg)
			end,
			-- we also want to start the domain up after we know the network
			-- is running, so go ahead and do that
			function (domain)
				domain:command_start_domain()
			end
		},
	}

	for signal, handlers in pairs(domain_signal_handlers) do
		for _, handler in ipairs(handlers) do
			domain:connect_signal(signal, handler)
		end
	end
end

return M
