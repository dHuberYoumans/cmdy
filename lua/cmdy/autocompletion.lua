local M = {}

local file_cmds = {
    edit = true,
    e = true,
    vsplit = true,
    hsplit = true,
    source = true,
}

local prompt_chars = {
    ["❯"] = true,
    [">"] = true,
    ["$"] = true,
    ["λ"] = true,
    ["%"] = true,
    ["#"] = true,
}

local function keys(str)
    return vim.api.nvim_replace_termcodes(str, true, true, true)
end

function M.smart_tab()
    local current_buf = vim.api.nvim_get_current_buf()

    vim.api.nvim_buf_call(current_buf, function()
        local cursor_col = vim.fn.col('.')
        local line = vim.fn.getline('.')
        -- strip leading prompt char if present
        local leading = vim.fn.strcharpart(line, 0, 1)
        if prompt_chars[leading] then 
            line = line:sub(#leading + 2)
        end
        local prefix = line:sub(1, cursor_col - 1)
        local args = vim.split(prefix, "%s+")
        local current_word = args[#args] or ""

        local context

        if #args == 1 then 
            context = "cmdline"
        elseif file_cmds[args[1]] then
            context = "file"
        elseif args[1] == "set" then
            context = "option"
        else 
            context = "cmdline"
        end

        local suggestions = vim.fn.getcompletion(current_word, context)
        if context == "file" and #args == 1 then
            local suggestions = ""
        end
        vim.fn.writefile({ "suggestions: " ..  vim.inspect(suggestions) }, "/tmp/cmdy-debug.log", "a")

        vim.schedule(function()
            vim.fn.complete(cursor_col - #current_word, suggestions)
        end)
    end)
    return ""
end

function M.setup(src_buf, target, buf)
    local src_path = vim.api.nvim_buf_get_name(src_buf)
    if src_path ~= "" then
        local dir = vim.fn.fnamemodify(src_path, ":h")
        vim.api.nvim_set_current_win(target)
        vim.cmd("lcd " .. vim.fn.fnameescape(dir))
    end
    vim.api.nvim_buf_call(buf, function()
        vim.cmd([[
            inoremap <buffer><expr> <Tab> v:lua.require'cmdy.autocompletion'.smart_tab()
            inoremap <buffer><expr> <CR> pumvisible() ? "\<C-y>" : "\<CR>"
            setlocal completeopt=menu,menuone,noselect
            ]])
    end)
end

return M
