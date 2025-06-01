local popup = require('plenary.popup')
local hl = require('cmdy.highlight')
local config = require('cmdy.config')

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

function M.create_prompt(buf, opts)

    local prompt_opts = {
        title = opts.title or config.options.prompt.title,
        width = opts.width or config.options.prompt.width,
        line = opts.row or config.options.prompt.line,
        col = opts.col or config.options.prompt.col,
        height = config.options.prompt.height,
        borderchars = config.options.prompt.borderchars,
    }

    hl.setup_highlights()

    local win_id, opts = popup.create(buf, prompt_opts)

    M.apply_highlights(win_id, opts.border.win_id)

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

function M.create_window(buf, opts)
    local win, win_opts = popup.create(buf, opts)
    return win, win_opts.border.win_id
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
