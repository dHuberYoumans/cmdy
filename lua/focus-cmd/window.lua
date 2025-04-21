local popup = require('plenary.popup')
local hl = require('focus-cmd.highlight')

local M = {}

hl.setup_hl_prompt_prefix()

function M.create_prompt_buffer(filetype)
    local buf = vim.api.nvim_create_buf(false,false)
    vim.api.nvim_buf_set_option(buf, "filetype", filetype)
    vim.api.nvim_buf_set_option(buf, "buftype", "prompt")
    vim.fn.prompt_setprompt(buf, "❯ ")
    vim.api.nvim_buf_set_option(buf, "bufhidden", "wipe")
    vim.api.nvim_buf_set_option(buf, "swapfile", false)
    vim.api.nvim_buf_set_option(buf, "buflisted", false)
    return buf
end

function M.create_window(buf, width, height, title)
    local borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" }
    win_id, opts = popup.create(buf,{
        title = title or "NORMAL MODE",
        row = math.floor(vim.o.lines / 2),
        col = math.floor((vim.o.columns - width) / 2),
        minwidth = width,
        minheight = height,
        borderchars = borderchars,
        highlight = "FocusedCmdNormal",
    })

    vim.api.nvim_buf_call(buf, function()
        vim.fn.matchadd("FocusCmdPromptChar", [[\v^❯]])
    end)

    return win_id, opts.border.win_id
end


function M.apply_highlights(win_id, border_win_id)
    vim.api.nvim_win_set_option(
        win_id,
        "winhighlight",
        "Normal:FocusedCmdNormal"
    )
    vim.api.nvim_win_set_option(
        border_win_id,
        "winhighlight",
        "Normal:FocusedCmdNormal,FloatBorder:FocusedCmdBorder"
    )
end

return M
