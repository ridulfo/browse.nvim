local utils = require("browse.utils")

local M = {}

local defaults = {
	download_path = "~/.browse",
}

M.options = {}

function M.setup(opts)
	M.options.download_path = opts.download_path or defaults.download_path
	M.options.download_path = utils.expand_tilde(M.options.download_path)
end

return M
