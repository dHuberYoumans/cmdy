local popup = require('plenary.popup')
local hl = require('focus-cmd.highlight')
local window = require('focus-cmd.window')
local search_hl = require('focus-cmd.search')

local M = {}

function M.open_cmd_window(arg)
    hl.setup_highlights()

    local og_win_id = vim.api.nvim_get_current_win()
    local og_buf_id = vim.api.nvim_get_current_buf()

    local buf = window.create_prompt_buffer("focus_cmd")
    local width, height = 60, 1
    local title = (arg == "/") and "SEARCH" or "NORMAL MODE"

    local win_id, border_id = window.create_window(buf, width, height, title)
    vim.defer_fn(function()
        window.apply_highlights(win_id, border_id)
    end,10)

    if arg == "/" then 
        search_hl.search_hl_live(buf, og_buf_id)
        vim.fn.prompt_setcallback(buf, function(input)
            search_hl.clear_hls(og_win_id)
            vim.api.nvim_win_close(0, true)
            vim.api.nvim_set_current_win(og_win_id)
            vim.cmd("/"..input)
        end)
    elseif arg == "::" then
        vim.fn.prompt_setcallback(buf, function(input)
            vim.defer_fn(function()
                vim.api.nvim_win_close(0, true)
                vim.api.nvim_set_current_win(og_win_id)
                vim.cmd(input)
            end, 1)
        end)
    end 


    vim.cmd("startinsert")

    vim.keymap.set({"n", "i"}, "<ESC>", function()
        vim.cmd("stopinsert")
        vim.api.nvim_win_close(win_id, true)
    end, { buffer = buf })
end

return M
