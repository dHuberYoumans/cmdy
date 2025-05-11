local M = {}

function M.get_current_line()
    local cursor_pos = vim.api.nvim_win_get_cursor(0)
    local row = cursor_pos[1]
    local line_content = vim.api.nvim_buf_get_lines(0, row-1, row, false)[1]
    return line_content
end

return M
