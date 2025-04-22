local popup = require('plenary.popup')
local hl = require('cmdy.highlight')
local window = require('cmdy.window')
local search = require('cmdy.search')

local M = {}

hl.setup_highlights()

local og_win_id = vim.api.nvim_get_current_win()
local og_buf_id = vim.api.nvim_get_current_buf()

function M.focus_search()
    local buf = window.create_prompt_buffer("focus_cmd")
    local title = "SEARCH"

    local win_id, border_id = window.create_window(buf, title)
    vim.defer_fn(function()
        window.apply_highlights(win_id, border_id)
    end,10)

    search.search_hl_live(buf, og_buf_id)
    vim.fn.prompt_setcallback(buf, function(input)
        search.clear_hls(og_win_id)
        vim.api.nvim_win_close(win_id, true)
        vim.api.nvim_set_current_win(og_win_id)
        vim.cmd("/"..input)
    end)
    vim.cmd("startinsert")
end

function M.focus_normal_mode()
    local buf = window.create_prompt_buffer("focus_cmd")
    local title = "NORMAL MODE"

    local win_id, border_id = window.create_window(buf, title)
    vim.defer_fn(function()
        window.apply_highlights(win_id, border_id)
    end,10)

    vim.fn.prompt_setcallback(buf, function(input)
        vim.api.nvim_win_close(0, true)
        vim.api.nvim_set_current_win(og_win_id)
        vim.schedule(function()
            vim.cmd(input)
        end,1)
    end)
    vim.cmd("startinsert")
end

return M
