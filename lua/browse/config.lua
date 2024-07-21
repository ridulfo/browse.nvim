local utils = require("browse.utils")

local M = {}


local defaults = {
	download_path = "~/.browse",
}

M.options = {}


function M.setup(opts)
	for k, v in pairs(defaults) do
		M.options[k] = opts[k] or v
	end

	M.options.download_path = utils.expand_tilde(M.options.download_path)
end


return M
