local popup = require('plenary.popup')
local utils = require('cmdy.utils')
local window = require('cmdy.window')
local hl = require('cmdy.highlight')
local search = require('cmdy.search')

local M = {}

function M.create_buffer_window()

    local width = math.floor(vim.o.columns * 0.75)
    local height = math.floor(2 * vim.o.lines / 3)
    local row = 3
    local col = math.floor((vim.o.columns - width)/2)
    local prompt_row = row + height + 1
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
        row = row,
        col = col,
        minwidth = width,
        minheight = height,
        borderchars = borderchars,
    })

    vim.api.nvim_win_set_option(win_id,"cursorline",true)

    window.apply_highlights(win_id, opts.border.win_id)
        
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
    
    vim.keymap.set({"n", "i"}, "<ESC>", function()
        vim.cmd("stopinsert")
        vim.api.nvim_win_close(0, true)
    end, { buffer = buf })

    vim.keymap.set({"n"}, "/", function()
        M.open_search_prompt(width, prompt_row , col)
    end, { buffer = buf })

    return win_id, opts.border.win_id
end

function M.open_search_prompt(width, row, col)
    local og_win_id = vim.api.nvim_get_current_win()
    local og_buf_id = vim.api.nvim_get_current_buf()
    local buf = window.create_prompt_buffer("focus_search", "/")

    local win_id, border_id = window.create_prompt(buf, "", width, row, col)
    vim.schedule(function()
        window.apply_highlights(win_id, border_id)
    end)

    search.search_hl_live(buf, og_buf_id)
    search.attach_callback(buf, og_win_id)
    vim.cmd("startinsert")
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
