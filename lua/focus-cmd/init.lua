local popup = require('plenary.popup')
local hl = require('focus-cmd.highlight')
local window = require('focus-cmd.window')

local M = {}

function M.open_cmd_window(arg)
    hl.setup_highlights()

    local og_win_id = vim.api.nvim_get_current_win()
    local buf = window.create_prompt_buffer("focus_cmd")

    local width, height = 60, 1

    local title = (arg == "/") and "SEARCH" or "NORMAL MODE"

    win_id, opts = window.create_window(buf, width, height, title)
    vim.defer_fn(function()
        window.apply_highlights(win_id, opts.border.win_id)
    end,10)

    vim.fn.prompt_setcallback(buf, function(input)
        vim.api.nvim_win_close(0, true)

        vim.defer_fn(function()
            vim.api.nvim_set_current_win(og_win_id)

            if arg == "/" then
                vim.cmd("/" .. input)
            elseif arg == "::" then
                vim.cmd(input)
            end
        end, 1)
    end)


    vim.cmd("startinsert")

    vim.keymap.set({"n", "i"}, "<ESC>", function()
        vim.cmd("stopinsert")
        vim.api.nvim_win_close(cmd_win_id, true)
    end, { buffer = buf })
end

return M
