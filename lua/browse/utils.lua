local M = {}

-- Expands a path that starts with a tilde
-- @param path The path to expand
-- @return The expanded path
M.expand_tilde = function(path)
	if path:sub(1, 1) == "~" then
		local home = os.getenv("HOME")
		if home then
			return home .. path:sub(2)
		else
			vim.notify("Failed to get home directory when expanding tilde", vim.log.levels.ERROR)
			return nil
		end
	end
	return path
end

-- Takes a URL and returns the webpage as Markdown
-- @param url The URL of the webpage
-- @return The webpage as Markdown
--
-- This is done by using Lua's io.popen to spawn a new process that runs
-- web2md.sh. Unfortunately, this hides error from the user.
M.fetch_url = function(url)
	-- Get the path of the current script
	local script_path = debug.getinfo(1, "S").source:sub(2)

	-- Extract the directory part of the script path
	local script_dir = script_path:match("(.*/)")
	local web2md_path = script_dir .. "web2md.sh"
	local cmd = "bash " .. web2md_path .. " " .. url

	-- Execute the script
	local handle, _ = io.popen(cmd)
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

	return result
end

-- Takes a URL and returns the path where the file should be saved
-- @param url The URL of the webpage
-- @param download_directory The directory to download the file to
-- @return The path where the file should be saved
M.file_path_from_url = function(url, download_directory)
	-- Steps:
	-- 1. Remove protocol prefix
	-- 2. Replace slashes with underscores #TODO: use tree-structure
	local filename = string.gsub(url, "https?://", "") .. ".md"
	filename = string.gsub(filename, "/", "_")

	return download_directory .. "/" .. filename
end

return M
