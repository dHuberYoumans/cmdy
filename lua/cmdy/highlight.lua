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

return M
