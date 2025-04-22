vim.keymap.set('n', '::', function()
  require('focus-cmd').focus_normal_mode()
end)

vim.keymap.set('n', '/', function()
  require('focus-cmd').focus_search()
end)
