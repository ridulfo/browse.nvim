local function extract_url(line)
	local pattern = "(https?://[%w%.%-]+/*[^%s)]*)"
	local url = string.match(line, pattern)
	return url
end

-- Define the custom gf function
function Custom_gf()
	local line = vim.api.nvim_get_current_line()

	local url = extract_url(line)

	if url then
		vim.api.nvim_command("Browse " .. url)
	else
		vim.api.nvim_command("normal! gf")
	end
end

local group = vim.api.nvim_create_augroup("browseAutos", {
	clear = true,
})

vim.api.nvim_create_autocmd({ "BufEnter" }, {
	group = group,
	pattern = "*",
	callback = function()
		vim.keymap.set("n", "gf", Custom_gf, { noremap = true, silent = true })
	end,
})
