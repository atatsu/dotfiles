local brazenutils = require("brazen.utils")

local markup = brazenutils.markup
local falsy = brazenutils.falsy

local function notify (message)
	brazenutils.notify_normal("VirshControl", message)
end

local function notifyerr (message)
	brazenutils.notify_error("VirshControl", message)
end

local M = {}

function M.connect_domain (virshcontrol, domain)
	local domain_signal_handlers = {
		["network::error"] = {
			function (domain, status)
				notifyerr(status.stderr)
			end,
		},
		-- fired when an actual domain item is clicked, signifying the user wishes
		-- to fire up the domain and its network (if any)
		["domain::start"] = {
			function (domain)
				print("starting domain " .. domain:get_domain())
				domain:check()
				domain:command_start_network()
			end,
		},
		-- fired when an already started domain item is clicked, signifying the user
		-- wishes to power down the domain and/or its network
		["domain::destroy"] = {
			function (domain)
				print("stopping domain " .. domain:get_domain())
				domain:uncheck()
			end,
		},
		-- fired when a domain status check finds that a domain's network is already
		-- running
		["network::running"] = {
			function (domain)
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
		["network::started"] = {
			function (domain)
				if falsy(domain:get_network()) then
					return
				end
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
