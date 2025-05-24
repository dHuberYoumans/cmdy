local popup = require('plenary.popup')
local hl = require('cmdy.highlight')
local window = require('cmdy.window')
local search = require('cmdy.search')
local replace = require('cmdy.replace')
local buffers = require('cmdy.buffers')
local autocmp = require('cmdy.autocompletion')
local config = require('cmdy.config')

local M = {}

hl.setup_highlights()


function M.focus_normal_mode()
    local src_win = vim.api.nvim_get_current_win()
    local src_buf = vim.api.nvim_get_current_buf()
    local buf = window.create_prompt_buffer("focus_normal_mode")

    local win, border = window.create_prompt(buf, {})
    vim.defer_fn(function()
        window.apply_highlights(win, border)
    end,10)
 
    autocmp.setup(src_buf, win, buf)

    vim.fn.prompt_setcallback(buf, function(input)
        vim.api.nvim_win_close(0, true)
        vim.api.nvim_set_current_win(src_win)
        vim.schedule(function()
            local ok,err = pcall(vim.cmd,input)
            if not ok then 
                vim.notify(err, vim.log.levels.ERROR) 
            end
        end,1)
    end)
    vim.cmd("startinsert")
end

function M.focus_search()
    local src_win = vim.api.nvim_get_current_win()
    local src_buf = vim.api.nvim_get_current_buf()
    local buf = window.create_prompt_buffer("focus_search", "/")

    local win, border = window.create_prompt(buf, config.search)
    vim.schedule(function()
        window.apply_highlights(win, border)
    end)

    search.search_hl_live(buf, src_buf)
    search.attach_callback(buf, src_win)
    vim.cmd("startinsert")
end

function M.focus_buffers()

    local opts = {
        display = config.buffer_window,
        prompt = config.buffer_window_prompt,
    }

    local src_win = vim.api.nvim_get_current_win()
    local win, border = buffers.create_buffer_window(opts)
    vim.schedule(function()
        window.apply_highlights(win, border)
    end)
    buffers.attach_callback(src_win)
end

function M.focus_replace()
    local src_win = vim.api.nvim_get_current_win()
    local src_buf = vim.api.nvim_get_current_buf()
    local to_replace = vim.fn.expand("<cword>")
    local cur_cursor_pos = vim.fn.getcurpos()
    local buf = window.create_prompt_buffer("focus_replace")
    local title = "REPLACE"
    local win, border = window.create_prompt(buf, title)
    vim.schedule(function()
        window.apply_highlights(win, border)
    end)
    replace.replace_with_live_preview(buf, src_win, src_buf, to_replace)
    replace.attach_callback(buf, src_win, cur_cursor_pos)
    vim.cmd("startinsert")
end

return M
