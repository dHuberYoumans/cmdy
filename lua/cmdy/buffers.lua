local popup = require('plenary.popup')
local utils = require('cmdy.utils')
local window = require('cmdy.window')
local hl = require('cmdy.highlight')

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

    hl.setup_highlights()
    
    local win_id, opts = popup.create(buf, {
        title = "BUFFER LIST",
        row = 3,
        col = math.floor((vim.o.columns - width)/2),
        minwidth = width,
        minheight = height,
        borderchars = borderchars,
    })

    vim.api.nvim_win_set_option(win_id,"cursorline",true)

    window.apply_highlights(win_id, opts.border.win_id)

    vim.schedule(function()
        vim.cmd('redraw!')
    end)

    vim.api.nvim_create_autocmd("ColorScheme", {
        buffer = buf,
        callback = function()
            vim.defer_fn(function()
                if vim.api.nvim_win_is_valid(win_id) and vim.api.nvim_win_is_valid(opts.border.win_id) then
                    window.apply_highlights(win_id, opts.border.win_id)
                end
            end, 15)
        end
    })

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
