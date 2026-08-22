local shell = {}

function shell.quote(value)
	return "'" .. value:gsub("'", "'\\''") .. "'"
end

return shell
