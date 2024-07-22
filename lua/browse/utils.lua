local M = {}

M.expand_tilde = function(path)
    if path:sub(1, 1) == '~' then
        local home = os.getenv("HOME")
        if home then
            return home .. path:sub(2)
        else
            vim.notify("Failed to get home directory", vim.log.levels.ERROR)
            return nil
        end
    end
    return path
end

return M
