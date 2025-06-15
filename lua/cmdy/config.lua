local M = {}

M.defaults = {}

function get_width() return math.floor(vim.o.columns * 0.75) end
function get_col() return math.floor((vim.o.columns - get_width()) / 2) end
function get_line() return math.floor(vim.o.lines / 2) end

-- global
local borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" }
local gap = 2
local offset_vertical = 3

-- prompt defaults
M.defaults.prompt = {
    title = "NORMAL MODE",
    width = get_width,
    line = get_line,
    col = get_col,
    height = 1,
    borderchars = borderchars,
}

-- cmdline
M.prompt_symbols = {
    ["$"] = true,
    ["λ"] = true,
    ["/"] = true,
    ["❯"] = true,
    [">"] = true,
}
M.defaults.cmdline = {
    prompt = "❯",
}

-- buffer list window (blsw)
local function blsw_width() return  math.floor(vim.o.columns * 0.75) end
local function blsw_height() return math.floor(vim.o.lines * 0.75) end
local function blsw_col() return math.floor((vim.o.columns - blsw_width())/2) end
local function blsw_minheight() return blsw_height() - gap end
local function blsw_maxheight() return blsw_height() - gap end
local function blsw_row() return 3 end
local function blsw_prompt_row() return blsw_row() + blsw_height() end

M.defaults.buffers = {
    buffer_window = {
        title = "BUFFER LIST",
        line = blsw_row,
        col = blsw_col,
        width = blsw_width,
        minheight = blsw_minheight,
        maxheight = blsw_maxheight,
        borderchars = borderchars,
    },
    buffer_window_prompt = {
        title = '',
        width = blsw_width,
        row =  blsw_prompt_row,
        col = blsw_col,
    }
}

-- search
M.defaults.search = {
    title = "SEARCH"
}

M.options = vim.deepcopy(M.defaults)

function M.setup(user_opts)
    user_opts = user_opts or {}
    M.options = vim.tbl_deep_extend("force", {}, M.defaults, user_opts)
end

return M
