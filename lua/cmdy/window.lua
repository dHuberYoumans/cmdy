local popup = require('plenary.popup')
local hl = require('cmdy.highlight')

local M = {}

hl.setup_hl_prompt_prefix()

function M.create_prompt_buffer(filetype, prompt)
    local prompt_str = (prompt or "❯").." "
    local buf = vim.api.nvim_create_buf(false,false)
    vim.api.nvim_buf_set_option(buf, "filetype", filetype)
    vim.api.nvim_buf_set_option(buf, "buftype", "prompt")
    vim.api.nvim_buf_set_option(buf, "bufhidden", "wipe")
    vim.api.nvim_buf_set_option(buf, "swapfile", false)
    vim.api.nvim_buf_set_option(buf, "buflisted", false)
    vim.fn.prompt_setprompt(buf, prompt_str)
    return buf
end

function M.create_prompt(buf, title)
    local width = math.floor(vim.o.columns * 0.75)
    local height = 1
    local borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" }
    hl.setup_highlights()
    local win_id, opts = popup.create(buf,{
        title = title or "NORMAL MODE",
        row = math.floor(vim.o.lines / 2),
        col = math.floor((vim.o.columns - width) / 2),
        minwidth = width,
        minheight = height,
        borderchars = borderchars,
        highlight = "FocusedCmdNormal",
    })
    vim.schedule(function()
        M.apply_highlights(win_id, opts.border.win_id)
    end)

    vim.api.nvim_buf_call(buf, function()
        vim.fn.matchadd("FocusCmdPromptChar", [[\v^(❯|\/)]])
    end)

    vim.keymap.set({"n", "i"}, "<ESC>", function()
        vim.cmd("stopinsert")
        vim.api.nvim_win_close(win_id, true)
    end, { buffer = buf })

    vim.api.nvim_create_autocmd("ColorScheme", {
        buffer = buf,
        callback = function()
            vim.defer_fn(function()
                if vim.api.nvim_win_is_valid(win_id) and vim.api.nvim_win_is_valid(opts.border.win_id) then
                    M.apply_highlights(win_id, opts.border.win_id)
                end
            end, 15)
        end
    })

    return win_id, opts.border.win_id
end

function M.apply_highlights(win_id, border_win_id)
    vim.api.nvim_win_set_option(
        win_id,
        "winhighlight",
        "Normal:FocusedCmdNormal,EndOfBuffer:FocusedCmdNormal"
    )
    vim.api.nvim_win_set_option(
        border_win_id,
        "winhighlight",
        "Normal:FocusedCmdNormal,FloatBorder:FocusedCmdBorder"
    )
end

return M
