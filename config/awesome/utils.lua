
local ipairs = ipairs
local awful = require("awful")
local screen = screen

module("utils")

function get_tag_by_name(tag_name, tags)
    for screen = 1, screen.count() do
	for index, tag in ipairs(tags[screen]) do
	    if tag.name == search_name then
		print(tag.screen)
		return tag
	    end
	end
	return 
    end
end
