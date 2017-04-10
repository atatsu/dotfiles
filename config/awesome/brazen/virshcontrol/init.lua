local path = (...):match("(.-)[^%.]+$")
return require(path .. "virshcontrol.virshcontrol")
