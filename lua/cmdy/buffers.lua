local utils = require('cmdy.utils')
local window = require('cmdy.window')
local hl = require('cmdy.highlight')
local search = require('cmdy.search')
local config = require('cmdy.config')

src = {
    win = nil,
    buf = nil,
}

local M = {}

function M.focus_buffers()
    local opts = {
        display = config.options.buffers.buffer_window,
        prompt = config.options.buffers.buffer_window_prompt,
    }
    src.win = vim.api.nvim_get_current_win()
    local win, border, buf = M.create_buffer_window(opts)
    vim.schedule(function()
        window.apply_highlights(win, border)
    end)
    M.attach_callback(src.win, buf)
end

function M.create_buffer_window(opts)

    local buf = vim.api.nvim_create_buf(false,true)
    vim.api.nvim_set_option_value("buftype", "nofile", {buf = buf})
    vim.api.nvim_set_option_value("bufhidden", "wipe", {buf = buf})
    vim.api.nvim_set_option_value("swapfile", false, {buf = buf})

    local output = vim.api.nvim_exec2("ls", { output = true }).output
    local lines = vim.split(output, "\n")
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    vim.schedule(function()
        vim.api.nvim_set_option_value("readonly", true, {buf = buf})
        vim.api.nvim_set_option_value("modifiable", false, {buf = buf})
    end)

    hl.setup_highlights()
    local win, border = window.create_window(buf, opts.display)

    vim.api.nvim_set_option_value("cursorline",false, {win = win})

    window.apply_highlights(win, border)

    M.search_prompt(opts.prompt, buf, win)

    vim.api.nvim_create_autocmd("ColorScheme", {
        buffer = buf,
        callback = function()
            vim.defer_fn(function()
                if vim.api.nvim_win_is_valid(win) and vim.api.nvim_win_is_valid(border) then
                    window.apply_highlights(win, border)
                end
            end, 15)
        end
    })

    vim.keymap.set({"n", "i"}, "<ESC>", function()
        vim.cmd("stopinsert")
        vim.api.nvim_win_close(0, true)
    end, { buffer = buf })

   vim.keymap.set({"n"}, "/", function()
       M.search_prompt(opts.prompt, buf, win)
   end, { buffer = buf })

    return win, border, buf
end

function M.search_prompt(opts, list_buf, list_win)
    local buf = window.create_prompt_buffer("search_prompt")

    local win, border = window.create_prompt(buf, opts)
    vim.schedule(function()
        window.apply_highlights(win, border)
    end)

    vim.api.nvim_buf_attach(0, false, {
        on_lines = function()
            update_buffer_list(buf, list_buf)
        end,
    })
    search.attach_callback(buf, list_win)
    search.search_hl_live(buf, list_buf)
    vim.cmd("startinsert")

    vim.keymap.set({"n", "i"}, "<ESC>", function()
        local line = vim.fn.getline('.')
        local pattern = vim.trim(line:sub(4))
        vim.cmd("stopinsert")
        if vim.api.nvim_win_is_valid(0) then
            vim.api.nvim_win_close(0, true)
        end
        if pattern == "" then
            search.clear_hls(list_win)
            if vim.api.nvim_win_is_valid(list_win) then
                vim.api.nvim_win_close(list_win, true)
            end
        elseif vim.api.nvim_win_is_valid(list_win) then
            vim.api.nvim_set_current_win(list_win)
        end
    end, { buffer = buf })
end

function update_buffer_list(prompt_buf, list_buf)
    local input = vim.api.nvim_buf_get_lines(prompt_buf, 0, 1, false)[1] or ""
    input = vim.trim(input:sub(4)) -- strip prompt char
    local output = vim.api.nvim_exec2("ls", { output = true }).output
    local lines = vim.split(output, "\n")
    local filtered_lines = lines
    if input ~= "" then
        filtered_lines = vim.tbl_filter(function(line)
            return line:lower():find(input:lower(), 1, true)
        end, lines)
    end
    utils.change_mutability(list_buf, true)
    vim.schedule(function()
        vim.api.nvim_buf_set_lines(list_buf, 0, -1, false, filtered_lines)
    end)
    utils.change_mutability(list_buf, false)
end

function M.attach_callback(target_win,list_buf)
    vim.keymap.set("n", "<CR>", function()
        local line = utils.get_current_line()
        local bufnr_to_load = tonumber(line:match("^%s*(%d+)"))
        vim.schedule(function()
            vim.api.nvim_win_close(0, true)
            vim.api.nvim_set_current_win(target_win)
        end)
        vim.schedule(function()
            vim.cmd("buffer "..bufnr_to_load)
        end)
    end, {buffer=list_buf})
end

return M
