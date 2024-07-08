local M = {}

M.settings = {
	number_of_files = 4,
}

function M.setup(user_settings)
	M.settings = vim.tbl_deep_extend("force", M.settings, user_settings)
end

local function get_grapple_files()
	local grapple = require("grapple")
	local files = {}
	local current_index = grapple.name_or_index()

	for i = 1, M.settings.number_of_files do
		if not grapple.exists({ index = i }) then
			break
		end
		local path = grapple.find({ index = i }).path
		local file = { path = path, current = i == current_index }
		table.insert(files, file)
	end

	return files
end

local function format_paths(files)
	for _, file in ipairs(files) do
		file.path = file.path:match("^.+/(.+)$")
	end
	return files
end

local function make_statusline(files)
	local result = {}
	for _, file in ipairs(files) do
		if file.current then
			table.insert(result, "%#lualine_a_normal# " .. file.path .. " %*")
		else
			table.insert(result, "%#lualine_a_inactive# " .. file.path .. " %*")
		end
	end
	return table.concat(result)
end

function M.status()
	local files = format_paths(get_grapple_files())
	return make_statusline(files)
end

return M
