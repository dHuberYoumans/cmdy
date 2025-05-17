local M = {}

local file_cmds = {
    edit = true,
    e = true,
    vsplit = true,
    hsplit = true,
    source = true,
}

local buffer_cmds = {
    b = true,
    buffer = true,
    bdelete = true,
    bd = true,
}

local shell_cmds = {
    ["!"] = true
}


local function keys(str)
    return vim.api.nvim_replace_termcodes(str, true, true, true)
end

function M.smart_tab()
    local cursor_col = vim.fn.col('.') - 1
    local line = vim.fn.getline('.')
    local before_cursor = line:sub(1, cursor_col)
    local words = vim.split(before_cursor, "%s+")
    local cur_word = words[1] or ""

    if file_cmds[cur_word] then 
        return keys("<C-x><C-f>") 
    else 
        return keys("<C-x><C-n>")
    end
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
            inoremap <buffer><expr> <Tab> pumvisible() ? "\<C-n>" : "\<C-x>\<C-f>"

            inoremap <buffer><expr> <CR> pumvisible() ? "\<C-y>" : "\<CR>"
            setlocal completeopt=menu,menuone,noselect
            ]])
    end)
end
   
return M
