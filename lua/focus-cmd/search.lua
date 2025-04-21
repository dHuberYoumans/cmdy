local M = {}

local last_match_id = nil

function M.update_search_hl(bufnr, win, pattern)   
    if last_match_id then
        vim.api.nvim_win_call(win,function()
            vim.fn.matchdelete(last_match_id)
        end)
        last_match_id = nil
    end

    if pattern == "" then
        vim.api.nvim_win_call(win, function()
            vim.fn.clearmatches()
        end)
        last_match_id = nil
        return 
    end

    if not win then return end

    -- highlight match inside win
    vim.api.nvim_win_call(win, function()
        last_match_id = vim.fn.matchadd("Search", pattern)
    end)
end

function M.search_hl_live(prompt_bufnr, target_bufnr) 
    -- find window hosting the target_buffer -> target_win
    local target_win = nil
    for _, win in ipairs(vim.api.nvim_list_wins()) do
        if vim.api.nvim_win_get_buf(win) == target_bufnr then
            target_win = win
            break
        end
    end

    vim.api.nvim_buf_attach(prompt_bufnr, false, {
    on_lines = function()
            local input = vim.api.nvim_buf_get_lines(prompt_bufnr,0,1,false)[1] or ""
            input = input:gsub("^❯ ", "")
            M.update_search_hl(target_bufnr, target_win, input)
        end,
    })
end

function M.clear_hls(win)
    if last_match_id then
        vim.api.nvim_win_call(win, function()
            vim.fn.matchdelete(last_match_id)
        end)
        last_match_id = nil
    end
end

return M
