--------------------------------------------------
-- Private – URL Handling and Custom 'gf' Mapping
--------------------------------------------------

-- Extract a URL from a line of text.
local function extract_url(line)
	local pattern = "(https?://[%w%.%-]+/*[^%s)]*)"
	return line:match(pattern)
end

-- When pressing 'gf', if a URL exists in the current line use it,
-- otherwise default to gf.
local function customGf()
	local line = vim.api.nvim_get_current_line()
	local url = extract_url(line)
	if url then
		-- Use fnameescape to handle spaces or special characters
		vim.cmd("Browse " .. vim.fn.fnameescape(url))
	else
		vim.cmd("normal! gf")
	end
end

-- Set up the custom 'gf' behavior by mapping it on every buffer.
local function setupCustomGf()
	local group = vim.api.nvim_create_augroup("browseAutos", { clear = true })
	vim.api.nvim_create_autocmd("BufEnter", {
		group = group,
		pattern = "*",
		callback = function()
			vim.keymap.set("n", "gf", customGf, { noremap = true, silent = true, buffer = 0 })
		end,
	})
end

--------------------------------------------------
-- Private – Download and File Path Utilities
--------------------------------------------------

-- Expand a tilde ('~') in a path to the user's home directory.
local function expandTilde(path)
	if path:match("^~[/\\]") or path == "~" then
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

-- Fetch the content of a URL by using an external script (web2md.sh)
-- placed in the same directory as this file.
local function fetchUrl(url)
	local script_path = debug.getinfo(1, "S").source:sub(2)
	local script_dir = script_path:match("(.*/)")
	if not script_dir then
		script_dir = "./"
	end
	local web2md_path = script_dir .. "web2md.sh"
	-- Escape the command parts so that spaces/special characters are handled
	local cmd = "bash " .. vim.fn.shellescape(web2md_path) .. " " .. vim.fn.shellescape(url)

	local handle = io.popen(cmd)
	if not handle then
		vim.notify("Failed to execute command " .. cmd, vim.log.levels.ERROR)
		return nil
	end

	local result = handle:read("*a")
	handle:close()

	if not result or result == "" then
		vim.notify("Failed to download " .. url, vim.log.levels.ERROR)
		return nil
	end

	return result
end

-- Construct a file path to save the webpage based on its URL.
local function filePathFromUrl(url, download_directory)
	-- Remove the scheme (http:// or https://)
	local url_no_scheme = url:gsub("^https?://", "")
	local domain, path = url_no_scheme:match("([^/]+)(/?.*)")
	if not domain then
		vim.notify("Invalid URL: " .. url, vim.log.levels.ERROR)
		return nil
	end

	-- If no path was provided (eg., "example.com") use "/" for the home directory.
	if path == "" then
		path = "/"
	end

	-- Create a base directory for the domain.
	local domain_dir = download_directory .. "/" .. domain
	os.execute("mkdir -p " .. vim.fn.shellescape(domain_dir))

	-- Break the path into segments.
	local segments = {}
	for segment in path:gmatch("([^/]+)") do
		table.insert(segments, segment)
	end

	local current_dir = domain_dir
	if #segments > 0 then
		-- Create all directories except for what might be the file/final segment.
		for i = 1, (#segments - 1) do
			current_dir = current_dir .. "/" .. segments[i]
			os.execute("mkdir -p " .. vim.fn.shellescape(current_dir))
		end
	end

	local filename = ""
	-- CASE 1: URL ends with a slash → treat as a directory.
	if path:sub(-1) == "/" then
		-- If there is a final named segment before the trailing slash, include it.
		if #segments > 0 then
			current_dir = current_dir .. "/" .. segments[#segments]
			os.execute("mkdir -p " .. vim.fn.shellescape(current_dir))
		end
		filename = "index.md"
		-- CASE 2: There are no segments (eg. "http://example.com") → use index.md at the domain level.
	elseif #segments == 0 then
		filename = "index.md"
	else
		local last_segment = segments[#segments]
		-- Check if the last segment appears to have a file extension (contains a dot).
		if not last_segment:find("%.") then
			-- No extension found – treat it as a directory.
			current_dir = current_dir .. "/" .. last_segment
			os.execute("mkdir -p " .. vim.fn.shellescape(current_dir))
			filename = "index.md"
		else
			-- It appears to be a file name.
			-- Option A: Simply append ".md" (as in your original code)
			-- filename = last_segment .. ".md"
			--
			-- Option B: Replace its extension with .md.
			local base = last_segment:match("(.+)%.[^%.]+$") or last_segment
			filename = base .. ".md"
		end
	end

	local full_path = current_dir .. "/" .. filename
	return full_path
end

--------------------------------------------------
-- Public API
--------------------------------------------------
local M = {}

-- Default configuration.
local defaults = {
	download_path = "~/.browse",
}

-- Module options (resolved during setup).
M.options = {}

-- Set up the Browse command and custom 'gf' mapping.
-- opts.download_path can be a path string or false.
M.setup = function(opts)
	opts = opts or {}
	local dp = opts.download_path

	if dp == nil then
		M.options.download_path = expandTilde(defaults.download_path)
	elseif dp == false then
		M.options.download_path = false
	else
		M.options.download_path = expandTilde(dp)
	end

	-- Create the Browse command.
	vim.api.nvim_create_user_command("Browse", function(command)
		if #command.fargs < 1 then
			vim.notify("Usage: Browse <url>", vim.log.levels.ERROR)
			return
		end
		if M.options.download_path == nil then
			vim.notify("No download path set", vim.log.levels.ERROR)
			return
		end

		local url = command.fargs[1]
		local content = fetchUrl(url)
		if not content then
			vim.notify("Failed to download " .. url, vim.log.levels.ERROR)
			return
		end

		if M.options.download_path == false then
			vim.cmd("vnew")
			local buf = vim.api.nvim_get_current_buf()
			vim.api.nvim_buf_set_name(buf, url)
			vim.bo.buftype = "nofile"
			vim.bo.bufhidden = "hide"
			vim.bo.filetype = "markdown"
			local new_lines = vim.split(content, "\n")
			local line_count = vim.api.nvim_buf_line_count(buf)
			vim.api.nvim_buf_set_lines(buf, 0, line_count, false, new_lines)
			vim.cmd("redraw!") -- Force a full redraw to clear any artifacts.
			return
		end

		local filepath = filePathFromUrl(url, M.options.download_path)
		if not filepath then
			vim.notify("Could not determine filepath for URL: " .. url, vim.log.levels.ERROR)
			return
		end

		local file, err = io.open(filepath, "w")
		if not file then
			vim.notify("Failed to open file " .. filepath .. ": " .. tostring(err), vim.log.levels.ERROR)
			return
		end

		file:write(content)
		file:close()
		-- Use fnameescape so that any special characters or spaces in the filename are handled
		vim.cmd("edit " .. vim.fn.fnameescape(filepath))
	end, {
		nargs = "+",
		desc = "Download a webpage and convert it to Markdown",
	})

	-- Set up the custom 'gf' mapping.
	setupCustomGf()
end

return M
