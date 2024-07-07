local M = {}

M.settings = {
	number_of_files = 4,
}

function M.setup(user_settings)
	M.settings = vim.tbl_deep_extend("force", M.settings, user_settings)
end

function M.status()
	local grapple = require("grapple")
	local result = {}
	local current_index = grapple.name_or_index()

	for i = 1, M.settings.number_of_files do
		if not grapple.exists({ index = i }) then
			break
		end
		local file_info = grapple.find({ index = i })
		local full_path = file_info.path
		local filename = full_path:match("^.+/(.+)$")

		if i == current_index then
			table.insert(result, "%#lualine_a_normal# " .. filename .. " %*")
		else
			table.insert(result, "%#lualine_a_inactive# " .. filename .. " %*")
		end
	end

	return table.concat(result)
end

return M
