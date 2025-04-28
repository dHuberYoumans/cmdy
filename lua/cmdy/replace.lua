local popup = require('plenary.popup')
local hl = require('cmdy.highlight')
local window = require('cmdy.window')
local search = require('cmdy.search')

local M = {}

function M.replace(to_replace, sub)
    local to_replace_escaped = vim.fn.escape(to_replace, '\\^$.*[]')
    local sub_escaped = vim.fn.escape(sub, '\\')
    vim.cmd(":%s/\\<"..to_replace_escaped.."\\>/"..sub_escaped.."/gI")
end

function M.preview_setup(prompt_bufnr, target_win_id, target_bufnr, to_replace)
    vim.api.nvim_win_call(target_win_id, function()
        vim.fn.setreg("/","\\<"..to_replace.."\\>")
        vim.cmd("set hls")
        vim.fn.search(to_replace)
    end)
end

function M.get_matches(target_win_id, pattern)
    local matches = {}
    local cur_cursor_pos = vim.fn.getcurpos()
    vim.api.nvim_win_call(target_win_id, function()
        local pattern_escaped = "\\<"..vim.fn.escape(pattern, "\\^$.*[]").."\\>"
        vim.cmd("normal! gg0")
        while vim.fn.search(pattern_escaped, "W") > 0 do
            local row = vim.fn.line(".") - 1 -- 0 indexed
            local col = vim.fn.col(".") - 1 -- 0 indexed
            table.insert(matches, {row=row, col=col})
        end
        vim.fn.setpos(".", cur_cursor_pos)
    end)
    return matches
end

function M.replace_with_live_preview(prompt_bufnr, target_win_id, target_bufnr, to_replace)
    for _, win in ipairs(vim.api.nvim_list_wins()) do
        if vim.api.nvim_win_get_buf(win) == target_win_id then
            target_win_id = win
            break
        end
    end
    M.preview_setup(prompt_bufnr, target_win_id, target_bufnr, to_replace) 
    local matches = M.get_matches(target_win_id, to_replace)
    vim.schedule(function()
            vim.api.nvim_win_call(target_win_id, function() 
                M.replace(to_replace, "")
            end)
        end)

    for _, match in ipairs(matches) do
        local line = vim.api.nvim_buf_get_lines(target_bufnr, match.row, match.row + 1, false)[1] or ""
        local before = line:sub(1, match.col)
        local after = line:sub(match.col + #to_replace + 1)
        vim.api.nvim_buf_attach(prompt_bufnr, false, {
            on_lines = function()
                local sub = vim.api.nvim_buf_get_lines(prompt_bufnr, 0, 1, false)[1] or ""
                sub = sub:gsub("^❯ ", "")
                if sub ~= "" then
                    vim.schedule(function()
                        local new_line = before..sub..after
                        vim.api.nvim_buf_set_lines(target_bufnr, match.row, match.row + 1, false, {new_line})
                    end)
                end
            end
        })
    end
end

function M.attach_callback(prompt_bufnr, target_win_id, cur_cursor_pos)
    vim.fn.prompt_setcallback(prompt_bufnr, function(sub)
        vim.api.nvim_win_close(0, true)
        vim.api.nvim_set_current_win(target_win_id)
        vim.schedule(function()
            vim.fn.setreg("/", sub)
            vim.cmd("set nohls")
            vim.fn.setpos(".", cur_cursor_pos)
        end)
    end)
end

return M
