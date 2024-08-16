local Utils = require("browse.utils")

local M = {}

local defaults = {
	download_path = "~/.browse",
}

M.options = {}

M.setup = function(opts)
	-- Set the options
	if opts.download_path == nil then
		M.options.download_path = Utils.expand_tilde(defaults.download_path)
	elseif opts.download_path == false then
		M.options.download_path = false
	else
		M.options.download_path = Utils.expand_tilde(opts.download_path)
	end

	-- Install the commands
	vim.api.nvim_create_user_command("Browse", function(opts)
		if #opts.fargs < 1 then
			vim.notify("Usage: Browse <url>", vim.log.levels.ERROR)
			return
		end

		if M.options.download_path == nil then
			vim.notify("No download path set", vim.log.levels.ERROR)
			return
		end

		local url = opts.fargs[1]

		local webpage = Utils.fetch_url(url)
		if webpage == nil then
			vim.notify("Failed to download " .. url, vim.log.levels.ERROR)
			return
		end

		-- Check if saving is enabled
		if M.options.download_path == false then
			-- Open a new buffer
			-- Name it after the URL
			-- Set type to markdown
			-- Set the lines
			vim.cmd("enew")
			vim.api.nvim_buf_set_name(0, url)
			vim.bo.buftype = "nofile"
			vim.bo.bufhidden = "hide"
			vim.bo.filetype = "markdown"
			vim.api.nvim_buf_set_lines(0, 0, -1, false, vim.split(webpage, "\n"))
			return
		else
			local filepath = Utils.file_path_from_url(url, M.options.download_path)
			local file = io.open(filepath, "w")
			if file == nil then
				vim.notify("Failed to open file " .. filepath, vim.log.levels.ERROR)
				return
			end

			file:write(webpage)
			file:close()

			vim.cmd("e " .. filepath)
		end
	end, {
		nargs = "+",
		desc = "Download a webpage and convert it to Markdown",
	})
end

return M
