local popup = require('plenary.popup')
local hl = require('cmdy.highlight')
local window = require('cmdy.window')
local search = require('cmdy.search')
local replace = require('cmdy.replace')

local M = {}

hl.setup_highlights()


function M.focus_normal_mode()
    local og_win_id = vim.api.nvim_get_current_win()
    local og_buf_id = vim.api.nvim_get_current_buf()
    local buf = window.create_prompt_buffer("focus_normal_mode")
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

function M.focus_search()
    local og_win_id = vim.api.nvim_get_current_win()
    local og_buf_id = vim.api.nvim_get_current_buf()
    local buf = window.create_prompt_buffer("focus_search")
    local title = "SEARCH"

    local win_id, border_id = window.create_window(buf, title)
    vim.defer_fn(function()
        window.apply_highlights(win_id, border_id)
    end,10)

    search.search_hl_live(buf, og_buf_id)
    search.attach_callback(buf, og_win_id)
    vim.cmd("startinsert")
end


function M.focus_replace()
    local og_win_id = vim.api.nvim_get_current_win()
    local og_bufnr = vim.api.nvim_get_current_buf()
    local to_replace = vim.fn.expand("<cword>")
    local cur_cursor_pos = vim.fn.getcurpos()
    vim.fn.search("\\<"..to_replace.."\\>")
    local buf = window.create_prompt_buffer("focus_replace")
    local title = "REPLACE"
    local win_id, border_id = window.create_window(buf, title)
    vim.schedule(function()
        window.apply_highlights(win_id, border_id)
    end)
    replace.replace_with_live_preview(buf, og_win_id, og_bufnr, to_replace)
    replace.attach_callback(buf, og_win_id, cur_cursor_pos)
    vim.cmd("startinsert")
end

return M
