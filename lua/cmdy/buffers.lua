local popup = require('plenary.popup')
local utils = require('cmdy.utils')

local M = {}

function M.create_buffer_window()

    local width = math.floor(vim.o.columns * 0.75)
    local height = math.floor(2 * vim.o.lines / 3)
    local borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" }

    local buf = vim.api.nvim_create_buf(false,true)
    vim.api.nvim_buf_set_option(buf, "buftype", "nofile")
    vim.api.nvim_buf_set_option(buf, "bufhidden", "wipe")
    vim.api.nvim_buf_set_option(buf, "swapfile", false)

    local output = vim.api.nvim_exec2("ls", { output = true }).output
    local lines = vim.split(output, "\n")
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

    local win_id, opts = popup.create(buf, {
        title = "BUFFER LIST",
        row = 3,
        col = math.floor((vim.o.columns - width)/2),
        minwidth = width,
        minheight = height,
        borderchars = borderchars,
        highlight = "FocusedCmdNormal",
    })

    vim.api.nvim_win_set_option(win_id,"cursorline",true)

    return win_id, opts.border.win_id
end

function M.attach_callback(target_win_id)
    vim.keymap.set("n", "<CR>", function()
        local line = utils.get_current_line()
        local bufnr_to_load = tonumber(line:match("^%s*(%d+)"))
        vim.schedule(function()
            vim.api.nvim_win_close(0, true)
            vim.api.nvim_set_current_win(target_win_id)
        end)
        vim.schedule(function()
            vim.cmd("buffer "..bufnr_to_load)
        end)
    end, {buffer=0})
end


return M
