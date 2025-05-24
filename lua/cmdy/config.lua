local M = {}
-- global
local borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" }
local gap = 2
local offset_vertical = 3

-- prompt defaults
M.prompt_defaults = {
        title = "NORMAL MODE",
        width = math.floor(vim.o.columns * 0.75),
        line = math.floor(vim.o.lines / 2),
        col = math.floor((vim.o.columns - math.floor(vim.o.columns * 0.75)) / 2),
        height = 1,
        borderchars = borderchars,
        --highlight = "FocusedCmdNormal",
    }


-- buffer list window (blsw)
local blsw_width = math.floor(vim.o.columns * 0.75)
local blsw_height = math.floor(vim.o.lines * 0.75)
local blsw_row = 3
local blsw_col = math.floor((vim.o.columns - blsw_width)/2)
local blsw_prompt_row = blsw_row + blsw_height

M.buffer_window = {
    title = "BUFFER LIST",
    line = blsw_row,
    col = blsw_col,
    width = blsw_width,
    minheight = blsw_height - gap,
    maxheight = blsw_height - gap,
    borderchars = borderchars,
}

M.buffer_window_prompt = {
    title = '',
    width = blsw_width,
    row =  blsw_prompt_row,
    col = blsw_col,
}

-- search
M.search = {
    title = "SEARCH"
}

return M
