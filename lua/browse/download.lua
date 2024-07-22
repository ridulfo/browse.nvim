local M = {}

M.download_and_save = function(url, download_directory)
	-- Get the path of the current script
	local script_path = debug.getinfo(1, "S").source:sub(2)
	-- Extract the directory part of the script path
	local script_dir = script_path:match("(.*/)")
	local web2md_path = script_dir .. "web2md.sh"
	local cmd = "bash " .. web2md_path .. " " .. url

	-- Execute the script
	local handle, err = io.popen(cmd)
	if handle == nil then
		vim.notify("Failed to execute command " .. url, vim.log.levels.ERROR)
		return
	end

	local result = handle:read("*a")
	handle:close()

	if result == nil or result == "" then
		vim.notify("Failed to download " .. url, vim.log.levels.ERROR)
		return
	end

	-- === Create file name ===
	-- 1. Remove protocol prefix
	-- 2. Replace slashes with underscores
	local filename = string.gsub(url, "https?://", "") .. ".md"
	filename = string.gsub(filename, "/", "_")

	local filepath = download_directory .. "/" .. filename
	local file = io.open(filepath, "w")
	if file == nil then
		vim.notify("Failed to open file " .. filepath .. ": " .. (err or "unknown error"), vim.log.levels.ERROR)
		return
	end

	file:write(result)
	file:close()

	return filepath
end

return M
