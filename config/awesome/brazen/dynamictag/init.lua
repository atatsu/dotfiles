local path = (...):match("(.-)[^%.]+$")
return require(path .. "dynamictag.dynamictag")
