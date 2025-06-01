local popup = require('plenary.popup')
local utils = require('cmdy.utils')
local window = require('cmdy.window')
local hl = require('cmdy.highlight')
local search = require('cmdy.search')
local config = require('cmdy.config')

src = {
    win = nil,
    buf = nil,
}

local M = {}

function M.focus_buffers()
    local opts = {
        display = config.options.buffers.buffer_window,
        prompt = config.options.buffers.buffer_window_prompt,
    }
    src.win = vim.api.nvim_get_current_win()
    local win, border = M.create_buffer_window(opts)
    vim.schedule(function()
        window.apply_highlights(win, border)
    end)
    M.attach_callback(src.win)
end

function M.create_buffer_window(opts)

    local buf = vim.api.nvim_create_buf(false,true)
    vim.api.nvim_buf_set_option(buf, "buftype", "nofile")
    vim.api.nvim_buf_set_option(buf, "bufhidden", "wipe")
    vim.api.nvim_buf_set_option(buf, "swapfile", false)

    local output = vim.api.nvim_exec2("ls", { output = true }).output
    local lines = vim.split(output, "\n")
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    vim.schedule(function()
        vim.api.nvim_buf_set_option(buf, "readonly", true)
        vim.api.nvim_buf_set_option(buf, "modifiable", false)
    end)

    hl.setup_highlights()
    local win, border = window.create_window(buf, opts.display)

    vim.api.nvim_win_set_option(win,"cursorline",false)

    window.apply_highlights(win, border)

    M.open_search_prompt(opts.prompt,win, buf)
        
    vim.api.nvim_create_autocmd("ColorScheme", {
        buffer = buf,
        callback = function()
            vim.defer_fn(function()
                if vim.api.nvim_win_is_valid(win) and vim.api.nvim_win_is_valid(border) then
                    window.apply_highlights(win, border)
                end
            end, 15)
        end
    })
 
    vim.keymap.set({"n", "i"}, "<ESC>", function()
        vim.cmd("stopinsert")
        vim.api.nvim_win_close(0, true)
    end, { buffer = buf })

   vim.keymap.set({"n"}, "/", function()
       M.open_search_prompt(opts.prompt,win, buf)
   end, { buffer = buf })

    return win, border 
end

function M.open_search_prompt(opts, src_win, src_buf)
    local buf = window.create_prompt_buffer("focus_search", "/")

    local win, border = window.create_prompt(buf, opts)
    vim.schedule(function()
        window.apply_highlights(win, border)
    end)

    search.search_hl_live(buf, src_buf)
    search.attach_callback(buf, src_win)
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
