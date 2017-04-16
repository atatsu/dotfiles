local awful = require("awful")

local brazenutils = require("brazen.utils")
local falsy = brazenutils.falsy

M = {}
local _ = {}

local function easy_async (cmd, cb)
	awful.spawn.easy_async(awful.util.shell .. " -c '" .. cmd .. "'", function (stdout, stderr, reason, code)
		if stderr and stderr ~= "" then
			print(stderr)
		end
		cb({ stdout = stdout, stderr = stderr, reason = reason, code = code })
	end)
end

function M.init (self)
	if tostring(self) == "virshdomain" then
		_[self] = {
			check_vm_status = function () return check_vm_status(self) end,
			monitor_domain_for_shutdown = function () return monitor_domain_for_shutdown(self) end,
			start_network = function () return start_network(self) end,
			start_domain = function () return start_domain(self) end,
			destroy_network = function () return destroy_network(self) end,
		}
	end
end

function check_vm_status (self)
	local _p = self._private
	-- start with network
	if _p.network then
		easy_async("virsh net-list | grep " .. _p.network, function (result)
			if result.code == 0 then
				self:emit_signal("network::status::running")
			else
				self:emit_signal("network::status::stopped")
			end
		end)
	end

	-- now the domain
	easy_async("virsh list | grep " .. _p.domain, function (result)
		if result.code == 0 then
			self:emit_signal("domain::status::running")
		else
			self:emit_signal("domain::status::stopped")
		end
	end)
end

-- watch the domain process so we know when it shuts down
function monitor_domain_for_shutdown (self)
	local _p = self._private
	-- need to escape the single quote used for awk as this command will be executed within
	-- single quotes
	local escaped = "'\"'\"'"
	-- now lets find the pid of the domain process
	local cmd = "ps aux | grep -v grep | grep qemu-system | grep -- \"-name guest=" .. _p.domain
		.. "\" | awk {" .. escaped .. "print $2" .. escaped .. "}"
	easy_async(cmd, function (result)
		if result.code ~= 0 then
			self:emit_signal("monitor::pid::error")
			return
		end

		local pid = result.stdout
		if falsy(pid) then
			self:emit_signal("monitor::pid::error")
			return
		end

		pid = pid:gsub("\n", "")
		local cmd = awful.util.shell .. " -c 'while [[ -e /proc/" .. pid .. " ]]; do sleep 10; done'"
		awful.spawn.with_line_callback(cmd, {
			exit = function (reason, code)
				self:emit_signal("monitor::status::exit")
			end,
			stderr = function (line)
				self:emit_signal("monitor::status::error", line)
			end,
		})
		self:emit_signal("monitor::status::active", pid)
	end)
end

function start_network (self)
	local _p = self._private
	local network = _p.network

	if falsy(network) then
		self:emit_signal("network::status::started")
		return
	end

	easy_async("virsh net-list | grep " .. network, function (result)
		if result.code == 0 then
			self:emit_signal("network::status::running")
		else
			easy_async("virsh net-start " .. network, function (result)
				if result.code == 0 then
					self:emit_signal("network::status::started")
				else
					self:emit_signal("network::status::error", result.stderr)
				end
			end)
		end
	end)
end

function destroy_network (self)
	local _p = self._private
	local network = _p.network

	if falsy(network) then
		self:emit_signal("network::status::destroyed")
		return
	end

	easy_async("virsh net-destroy " .. network, function (result)
		if result.code ~= 0 then
			self:emit_signal("network::status::error", result.stderr)
			return
		end

		self:emit_signal("network::status::destroyed")
	end)
end

function start_domain (self)
	local _p = self._private
	local domain = _p.domain

	easy_async("virsh start " .. domain, function (result)
		if result.code == 0 then
			self:emit_signal("domain::status::started")
			return
		end

		self:emit_signal("domain::status::error", result.stderr)
	end)
end

return setmetatable(M, {
	__index = function (table, key)
		return _[key]
	end,
})
