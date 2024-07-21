local config = require("browse.config")
local browse = require("browse")

local function extract_url(line)
	local pattern = "(https?://[%w%.%-]+/[^%s)]*)"
	local url = string.match(line, pattern)
	return url
end

-- Define the custom gf function
function Custom_gf()
	local line = vim.api.nvim_get_current_line()

	local url = extract_url(line)

	if url == nil then
		vim.notify("No URL found under the cursor", vim.log.levels.ERROR)
		return
	end

	-- === Create file name ===
	-- 1. Remove protocol prefix
	-- 2. Replace slashes with underscores
	local filename = string.gsub(url, "https?://", "") .. ".md"
	filename = string.gsub(filename, "/", "_")

	local filepath = config.options.download_path .. "/" .. filename

	vim.notify("Downloading " .. url .. " to " .. filepath)

	vim.api.nvim_command("Browse " .. url .. " " .. filepath)
end
--
local group = vim.api.nvim_create_augroup("browseAutos", {
	clear = true,
})

vim.api.nvim_create_autocmd({ "BufEnter" }, {
	group = group,
	pattern = "*",
	callback = function()
		-- vim.api.nvim_buf_set_keymap(0, "n", "gf", ":lua Custom_gf()<CR>", { noremap = true, silent = true })
		vim.keymap.set("n", "gf", Custom_gf, { noremap = true, silent = true })
	end,
})
