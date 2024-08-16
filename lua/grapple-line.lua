local M = {}

---@class grapple-line.settings
M.settings = {
	---The number of files to display
	---@type integer
	number_of_files = 4,

	---@class grapple-line.colors
	---@field active string
	---@field inactive string

	---The highlights to use in the statusline
	---@type grapple-line.colors
	colors = {
		active = "lualine_a_normal",
		inactive = "lualine_a_inactive",
	},

	---@alias grapple-line.mode
	---| "unique_filename" Show the filename and parent directories if needed
	---| "filename" Show the filename only

	---The mode used for displaying tags
	---@type grapple-line.mode
	mode = "unique_filename",

	---Whether to use tag names when available
	---@type boolean
	show_names = false,

	---@alias grapple-line.overflow
	---| "none" Overflowing files are ignored
	---| "ellipsis" If there are overflowing files an ellipsis will be shown

	---How to display overflowing files
	---@type grapple-line.overflow
	overflow = "none",

	---Show parent dir for the following files
	---@type string[]
	show_parent_for_files = {},
}

---@param user_settings grapple-line.settings
function M.setup(user_settings)
	M.settings = vim.tbl_deep_extend("force", M.settings, user_settings)
end

---@class grapple-line.file
---@field path string
---@field current boolean
---@field tag_name string
---@field name string?
---@field count integer?

---@return grapple-line.file[]
local function get_grapple_files()
	local grapple = require("grapple")

	---@type grapple-line.file[]
	local files = {}

	local current_path = vim.api.nvim_buf_get_name(0)

	for i = 1, M.settings.number_of_files do
		if not grapple.exists({ index = i }) then
			break
		end
		local tag = grapple.find({ index = i }) --[[@as grapple.tag]]
		local path = tag.path

		---@type grapple-line.file
		local file = { path = path, current = path == current_path, tag_name = tag.name }

		table.insert(files, file)
	end

	return files
end

---@return string
local function make_ellipsis()
	local grapple = require("grapple")
	local current_path = vim.api.nvim_buf_get_name(0)
	local ellipsis = "..."
	local found_file = false
	local found_current_file = false

	for i = M.settings.number_of_files + 1, 9999 do
		if not grapple.exists({ index = i }) then
			break
		end
		found_file = true
		local tag = grapple.find({ index = i }) --[[@as grapple.tag]]
		if tag.path == current_path then
			found_current_file = true
			break
		end
	end

	if not found_file then
		return ""
	end

	local color = found_current_file and M.settings.colors.active or M.settings.colors.inactive
	return "%#" .. color .. "# " .. ellipsis .. " %*"
end

---@param files grapple-line.file[]
---@return string
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
	if M.settings.overflow == "ellipsis" then
		table.insert(result, make_ellipsis())
	end
	return table.concat(result)
end

---@param files grapple-line.file[]
---@return table<string, integer>
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

---@param files grapple-line.file[]
local function update_counts(files)
	local counts = get_counts(files)
	for _, file in ipairs(files) do
		file.count = counts[file.name]
	end
end

---@param path string
---@param depth integer?
---@return string
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

---@param files grapple-line.file[]
local function generate_initial_names(files)
	for _, file in ipairs(files) do
		file.name = get_name(file.path)
	end
end

---@param files grapple-line.file[]
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

---@param files grapple-line.file[]
local function make_names(files)
	generate_initial_names(files)

	for _, file in ipairs(files) do
		if vim.tbl_contains(M.settings.show_parent_for_files, file.name) then
			file.name = get_name(file.path, 2)
		end
	end

	if M.settings.mode == "unique_filename" then
		resolve_duplicates(files)
	end
end

---Get the status string
---@return string
function M.status()
	local files = get_grapple_files()
	make_names(files)
	return make_statusline(files)
end

return M
