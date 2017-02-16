local M = {
	stash = require("prefs.stash"),
	rules = function () 
		return require("prefs.rules")
	end ,
	signals = require("prefs.signals")
}

return M
