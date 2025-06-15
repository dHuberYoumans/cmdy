local M = {}

function M.get_current_line()
    local cursor_pos = vim.api.nvim_win_get_cursor(0)
    local row = cursor_pos[1]
    local line_content = vim.api.nvim_buf_get_lines(0, row-1, row, false)[1]
    return line_content
end

function M.change_mutability(buf, mutable)
    vim.schedule(function()
        vim.api.nvim_buf_set_option(buf, "modifiable", mutable)
        vim.api.nvim_buf_set_option(buf, "readonly", not mutable)
    end)
end

function M.resolve(val) 
    return type(val) == 'function' and val() or val
end

return M
