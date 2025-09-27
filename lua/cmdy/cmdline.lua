local window = require('cmdy.window')
local config = require('cmdy.config')
local hl = require('cmdy.highlight')

local state = {
    mirror = nil,
    mirror_opts = nil,
    buf = nil,
}

local src = {
 win = nil,
 buf = nil,
}

local prompt = config.options.cmdline.prompt

local M = {fn = {}}
local fn = {}

local function clean_states()
    if state.mirror and vim.api.nvim_win_is_valid(state.mirror) then
        pcall(vim.api.nvim_win_close, state.mirror, true)
    end
    if state.buf and vim.api.nvim_buf_is_valid(state.buf) then
        pcall(vim.api.nvim_buf_delete, state.buf, { force = true })
    end
    state.buf = nil
    state.mirror = nil
end

function M.mirror_cmdline()
    local border
    state.buf = vim.api.nvim_create_buf(false,true)
    vim.api.nvim_set_option_value("buftype", "nofile", { buf = state.buf})
    vim.api.nvim_set_option_value("bufhidden", "hide", { buf = state.buf})
    vim.api.nvim_set_option_value("swapfile", false, { buf = state.buf} )
    state.mirror, border = window.create_window(state.buf, config.options.prompt)
    hl.setup_highlights()
    window.apply_highlights(state.mirror, border)
    local line = vim.fn.getcmdline()
    vim.api.nvim_buf_set_lines(state.buf, 0, -1, false, {prompt .. " " .. line})
    vim.api.nvim_buf_call(state.buf, function()
        hl.hl_prompt(prompt)
    end)
    vim.cmd('redraw')
end

vim.api.nvim_create_autocmd("BufEnter", {
    callback = function()
        vim.keymap.set('n','<leader>w', function() M.mirror_cmdline() end)
    end
})

function fn.update_cmdline_content()
    if not (state.mirror and vim.api.nvim_win_is_valid(state.mirror)) then
        return
    end
    local line = vim.fn.getcmdline()
    if state.buf and vim.api.nvim_buf_is_valid(state.buf) then
        local ok, err = pcall(function ()
            vim.api.nvim_buf_set_lines(
                state.buf,
                0,
                1,
                false,
                {prompt .. " " .. line}
            )
            vim.api.nvim_buf_call(state.buf, function()
                hl.hl_prompt(prompt)
            end)
        end)
        if not ok then
            vim.notify("update skipped: " .. err, vim.log.levels.DEBUG)
        end
        vim.cmd('redraw')
    end
end

vim.api.nvim_create_autocmd("CmdlineEnter", {
    callback = function()
            src.win = vim.api.nvim_get_current_win()
            src.buf = vim.api.nvim_get_current_buf()
            clean_states()
            vim.schedule(function()
                M.mirror_cmdline()
            end)
    end,
})

vim.api.nvim_create_autocmd("CmdlineChanged", {
    callback = function()
        vim.schedule(function()
            fn.update_cmdline_content()
        end)
    end,
})

vim.api.nvim_create_autocmd("CmdlineLeave", {
    callback = function()
	vim.api.nvim_set_current_win(src.win)
	vim.api.nvim_set_current_buf(src.buf)
        vim.schedule(function()
            clean_states()
        end)
    end,
})

return M
