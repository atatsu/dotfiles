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
	_[self] = {
		check_vm_status = function () return check_vm_status(self) end,
		start_network = function () return start_network(self) end,
	}
end

function check_vm_status (self)
	local _p = self._private
	-- start with network
	if _p.network then
		easy_async("virsh net-list | grep " .. _p.network, function (result)
			if result.code == 0 then
				self:emit_signal("network::running", self)
			else
				self:emit_signal("network::stopped", self)
			end
		end)
	end
end

function start_network (self)
	local _p = self._private
	local network = _p.network

	if falsy(network) then
		self:emit_signal("network::started", self)
		return
	end

	easy_async("virsh net-list | grep " .. network, function (result)
		if result.code == 0 then
			self:emit_signal("network::running")
		else
			easy_async("virsh net-start " .. network, function (result)
				if result.code == 0 then
					self:emit_signal("network::started", self)
				else
					self:emit_signal("network::error", self, result)
				end
			end)
		end
	end)
end

return setmetatable(M, {
	__index = function (table, key)
		return _[key]
	end
})
