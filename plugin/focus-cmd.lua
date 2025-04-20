local popup = require('plenary.popup')

local M = {}

local normal_hl = vim.api.nvim_get_hl(0, { name = "Normal" })
vim.api.nvim_set_hl(0, "FocusedCmdNormal", normal_hl)

local border_hl = vim.api.nvim_get_hl(0, { name = "FloatBorder" })
vim.api.nvim_set_hl(0, "FocusedCmdBorder", border_hl)

function M.open_cmd_window(arg)
    local og_win_id = vim.api.nvim_get_current_win()
    local buf = vim.api.nvim_create_buf(false,false)
    vim.api.nvim_buf_set_option(buf, "filetype", "focused_cmd")
    vim.api.nvim_buf_set_option(buf, "buftype", "prompt")
    vim.fn.prompt_setprompt(buf, "❯ ")
    vim.api.nvim_buf_set_option(buf, "bufhidden", "wipe")
    vim.api.nvim_buf_set_option(buf, "swapfile", false)
    vim.api.nvim_buf_set_option(buf, "buflisted", false)
    local width = 60
    local height = 1
    local borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" }

    local title = "CMD"
    if arg == "/" then
        title = "SEARCH"
    end

    local cmd_win_id, win = popup.create(buf,{
        title = title,
        row = math.floor(vim.o.lines / 2),
        col = math.floor((vim.o.columns - width) / 2),
        minwidth = width,
        minheight = height,
        borderchars = borderchars,
        highlight = "FocusedCmdNormal",
    })


    vim.api.nvim_win_set_option(og_win_id, 'winhl', winhl)
    vim.api.nvim_win_set_option(
        win.border.win_id,
        "winhl",
        "Normal:FocusedCmdBorder"
    )

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
