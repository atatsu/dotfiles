local naughty = require("naughty")

local M = {}

function M.notify_normal (title, text)
	naughty.notify({
		preset = naughty.config.presets.normal,
		title = title,
		text = text
	})
end

function M.notify_error (title, text)
	naughty.notify({
		preset = naughty.config.presets.critical,
		title = title,
		text = text
	})
end

function easy_async (cmd, cb, notify_err)
	awful.spawn.easy_async(awful.util.shell .. " -c '" .. cmd .. "'", function (stdout, stderr, reason, code)
		if stderr and stderr ~= "" then
			print(stderr)
			if notify_err then notify_err(stderr) end
		end

		cb({ stdout = stdout, stderr = stderr, reason = reason, code = code })
	end)
end

function M.markup (args)
	if not args.text then 
		print("brazen.utils.markup called with no text argument, mistake?")
		return "" 
	end

	local markup = "<span"
	if args.color then
		markup = markup .. " foreground=\"" .. args.color .. "\""
	end

	if args.bold then
		local bold = "bold"
		if type(args.bold) == "string" then
			bold = args.bold
		end
		markup = markup .. " font_weight=\"" .. bold .. "\""
	end

	if args.italic then
		markup = markup .. " font_style=\"italic\""
	end

	if args.underline then
		local underline = "single"
		if type(args.underline) == "string" then
			underline = args.underline
		end
		markup = markup .. " underline=\"" .. underline .. "\""
	end

	if args.strike then
		markup = " strikethrough=\"true\""
	end

	markup = markup .. ">" .. args.text .. "</span>"

	if args.subscript then
		markup = "<sub>" .. markup .. "</sub>"
	end

	if args.superscript then
		markup = "<sup>" .. markup .. "</sup>"
	end

	if args.mono then
		markup = "<tt>" .. markup .. "</tt>"
	end

	if args.small then
		markup = "<small>" .. markup .. "</small>"
	end

	return markup
end

return M
