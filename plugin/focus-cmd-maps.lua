vim.keymap.set('n', '::', function()
  require('focus-cmd').open_cmd_window('::')
end)

vim.keymap.set('n', '/', function()
  require('focus-cmd').open_cmd_window('/')
end)
