local M = {}

M.settings = {
	number_of_files = 4,
	colors = {
		active = "lualine_a_normal",
		inactive = "lualine_a_inactive",
	},
	-- Accepted values:
	-- "unique_filename" shows the filename and parent directories if needed
	-- "filename" shows the filename only
	mode = "unique_filename",
	-- If a tag name is set, use that instead of the filename
	show_names = false,
}

function M.setup(user_settings)
	M.settings = vim.tbl_deep_extend("force", M.settings, user_settings)
end

local function get_grapple_files()
	local grapple = require("grapple")
	local files = {}
	local current_path = vim.api.nvim_buf_get_name(0)

	for i = 1, M.settings.number_of_files do
		if not grapple.exists({ index = i }) then
			break
		end
		local tag = grapple.find({ index = i })
		local path = tag.path
		local file = { path = path, current = path == current_path, tag_name = tag.name }
		table.insert(files, file)
	end

	return files
end

local function make_statusline(files)
	local result = {}
	for _, file in ipairs(files) do
		local color = file.current and M.settings.colors.active or M.settings.colors.inactive

		local text = ""
		if file.tag_name and M.settings.show_names then
			text = "[" .. file.tag_name .. "]"
		else
			text = file.name
		end

		table.insert(result, "%#" .. color .. "# " .. text .. " %*")
	end
	return table.concat(result)
end

local function get_counts(files)
	local counts = {}
	for _, file in ipairs(files) do
		counts[file.name] = counts[file.name] or 0
		if not file.tag_name then
			counts[file.name] = counts[file.name] + 1
		end
	end
	return counts
end

local function update_counts(files)
	local counts = get_counts(files)
	for _, file in ipairs(files) do
		file.count = counts[file.name]
	end
end

local function get_name(path, depth)
	depth = depth or 1
	local parts = {}
	for part in string.gmatch(path, "[^/]+") do
		table.insert(parts, part)
	end

	local resultParts = {}
	for i = #parts - depth + 1, #parts do
		table.insert(resultParts, parts[i])
	end

	return table.concat(resultParts, "/")
end

local function generate_initial_names(files)
	for _, file in ipairs(files) do
		file.name = get_name(file.path)
	end
end

local function resolve_duplicates(files)
	local duplicates = true
	local depth = 2
	while duplicates do
		duplicates = false
		update_counts(files)
		for _, file in ipairs(files) do
			if file.count > 1 then
				duplicates = true
				file.name = get_name(file.path, depth)
			end
		end
		depth = depth + 1
	end
end

local function make_names(files)
	generate_initial_names(files)
	if M.settings.mode == "unique_filename" then
		resolve_duplicates(files)
	end
end

function M.status()
	local files = get_grapple_files()
	make_names(files)
	return make_statusline(files)
end

return M
