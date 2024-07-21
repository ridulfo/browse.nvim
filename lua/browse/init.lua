local config = require("browse.config")

local M = {}

M.setup = config.setup

-- Downloads a webpage and converts it to Markdown
-- @param url The URL of the webpage to download
-- @return The Markdown content of the webpage
local function download_convert(url)
	local cmd = "bash web2md.sh " .. url
	local handle = io.popen(cmd)

	if handle == nil then
		vim.notify("Failed to download " .. url, vim.log.levels.ERROR)
		return
	end
	local result = handle:read("*a")
	handle:close()

	return result
end

function Download(url)
	local result = download_convert(url)
	if result == nil then
		vim.notify("Failed to download " .. url, vim.log.levels.ERROR)
		return
	end

	local filename = string.gsub(url, "https?://", "") .. ".md"
	filename = string.gsub(filename, "/", "_")

	if config.options.download_path == nil then
		vim.notify("Download path is not set", vim.log.levels.ERROR)
		return
	end

	local filepath = config.options.download_path .. "/" .. filename
	vim.notify("Downloading " .. url .. " to " .. filepath)

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
