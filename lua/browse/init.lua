local config = require("browse.config")

local M = {}

M.setup = config.setup


function Download(url)
	-- Get the path of the current script
	local script_path = debug.getinfo(1, "S").source:sub(2)
	local cmd = "bash " .. script_path:gsub("init.lua", "web2md.sh") .. " " .. url

	-- Execute the script
	local handle = io.popen(cmd)

	if handle == nil  then
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
	--

	local filename = string.gsub(url, "https?://", "") .. ".md"
	filename = string.gsub(filename, "/", "_")

	if config.options.download_path == nil then
		vim.notify("Download path is not set", vim.log.levels.ERROR)
		return
	end

	local filepath = config.options.download_path .. "/" .. filename

	vim.notify("Downloading " .. url .. " to " .. filepath, vim.log.levels.DEBUG)

	local file = io.open(filepath, "w")
	if file == nil then
		vim.notify("Failed to open file " .. filepath, vim.log.levels.ERROR)
		return
	end

	file:write(result)
	file:close()

	return filepath
end

-- Create user command
vim.api.nvim_create_user_command("Browse", function(opts)
	if #opts.fargs < 1 then
		vim.notify("Usage: Browse <url>", vim.log.levels.ERROR)
		return
	end

	local url = opts.fargs[1]

	local filepath = Download(url)

	if filepath == nil then
		vim.notify("Failed to download " .. url, vim.log.levels.ERROR)
	end

	vim.cmd("vsplit " .. filepath)
end, {
	nargs = "+",
	desc = "Download a webpage and convert it to Markdown",
})

return M
