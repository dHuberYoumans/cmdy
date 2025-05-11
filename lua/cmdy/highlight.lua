local M = {}

function M.setup_highlights()
    local normal_hl = vim.api.nvim_get_hl(0, { name = "Normal" })
    vim.api.nvim_set_hl(0, "FocusedCmdNormal", normal_hl)

    local border_hl = vim.api.nvim_get_hl(0, { name = "FloatBorder" })
    vim.api.nvim_set_hl(0, "FocusedCmdBorder", border_hl)
end

function M.setup_hl_prompt_prefix()
    vim.api.nvim_set_hl(0, "FocusCmdPromptChar", {
        fg = vim.api.nvim_get_hl(0, { name = "Special" }).fg,
        bold = true,
    })
end

M.setup_highlights()
M.setup_hl_prompt_prefix()

vim.defer_fn(function()
    vim.api.nvim_create_augroup("FocusedCmdHighlights", { clear = true })
    vim.api.nvim_create_autocmd("ColorScheme", {
        group = "FocusedCmdHighlights",
        callback = function()
            vim.defer_fn(function()
                M.setup_highlights()
                M.setup_hl_prompt_prefix()
                vim.cmd('redraw!')
            end,10)
        end
    })
end,0)

return M
