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

local M = {fn = {}}
local fn = {}

function M.mirror_cmdline()
    state.buf = vim.api.nvim_create_buf(false,true)
    state.mirror, border = window.create_window(state.buf, config.prompt_defaults)

    hl.setup_highlights()
    window.apply_highlights(state.mirror, border)

    local line = vim.fn.getcmdline()
    vim.api.nvim_buf_set_lines(state.buf, 0, -1, false, {":" .. line})
    
    vim.cmd('redraw')
end

vim.api.nvim_create_autocmd("BufEnter", {
    callback = function()
        vim.keymap.set('n','<leader>w', function() M.mirror_cmdline() end)
    end
})

function fn.update_cmdline_content()
    local line = vim.fn.getcmdline()
    if state.buf then vim.api.nvim_buf_set_lines(state.buf,0,-1,false, {":"..line}) end
    vim.cmd('redraw')
end

vim.api.nvim_create_autocmd("CmdlineEnter", {
    callback = function()
        src.win = vim.api.nvim_get_current_win()
        src.buf = vim.api.nvim_get_current_buf()
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
            if vim.api.nvim_win_is_valid(state.mirror) then
                vim.api.nvim_win_close(state.mirror, true)
            end
        end)
    end,
})

return M
