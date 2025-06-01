local config = require('cmdy.config')
config.setup({})

local search = require('cmdy.search')
local replace = require('cmdy.replace')
local buffers = require('cmdy.buffers')
local cmdline = require('cmdy.cmdline')

local M = {
    focus_cmdline = cmdline.mirror_cmdline,
    focus_search = search.focus_search,
    focus_buffers = buffers.focus_buffers,
    focus_replace = replace.focus_replace,
}

return M
