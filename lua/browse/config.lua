local Utils = require("browse.utils")
local Download = require("browse.download")

local M = {}

local defaults = {
	download_path = "~/.browse",
}

M.options = {}

M.setup = function(opts)
	M.options.download_path = opts.download_path or defaults.download_path
	M.options.download_path = Utils.expand_tilde(M.options.download_path)

	vim.api.nvim_create_user_command("Browse", function(opts)
		if #opts.fargs < 1 then
			vim.notify("Usage: Browse <url>", vim.log.levels.ERROR)
			return
		end

		local url = opts.fargs[1]

		if M.options.download_path == nil then
			vim.notify("No download path set", vim.log.levels.ERROR)
			return
		end

		local filepath = Download.download_and_save(url, M.options.download_path)

		if filepath == nil then
			vim.notify("Failed to download " .. url, vim.log.levels.ERROR)
		end

		vim.cmd("vsplit " .. filepath)
	end, {
		nargs = "+",
		desc = "Download a webpage and convert it to Markdown",
	})
end

return M
