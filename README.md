# cmdy

## Welcome..

...to **cmdy**, a small work-in-progress, learning-by-doing-failing-redoing-Q-and-A-with-you-favorite-LLM neovim plugin. This is my first trip down the rabbot hole, my first dance with the Cheshire Cat. Since this is a learning project, I'm happy about any constructive feedback. If you see something which doesn't make sense - please let me know. If you spot something which is wrong - please let me know. If you see something that you like - please let me know. The greatest feedback would be educational in the sense of why you would do x instead of y. 

So long, and thanks for all the fish! 

## The problem we are trying to solve

In fact, there is no problem, which makes the solution so much nicer to discover. Inspired by awesome plugins like [telescope](https://github.com/nvim-telescope/telescope.nvim) or [harpoon](https://github.com/ThePrimeagen/harpoon), we wanted to bring the cmd line into scope by simply opening a focused prompt in the middle of the screen when searching or executing :-commands. That's it.

## What's innit for you 

* a focused cmd line to write :-commands
* a focused search prompt
* a focused replace-all prompt
* a focusd window listing open buffers

## 📸
<img width="330" alt="focused-buffer" src="https://github.com/user-attachments/assets/0a39c801-2916-4e9b-83d3-360c2fa7218f" />
<img width="330" alt="focused-search" src="https://github.com/user-attachments/assets/612ec3bf-c799-4a7f-b9fc-1b7b6f8c03fd" />
<img width="330" alt="focused-normal-mode" src="https://github.com/user-attachments/assets/067d6a05-83ee-41d3-b367-a25e27a68304" />

## WIP 

* implement cmd-auto-completion 
* dynamic resizing of prompt buffers 
* place search prompt in buffer list below the focus window

## A bug's life 🐛

**replace-all**

When replacing all, all but the _very first line_ will be replaced. Suppose that we are editing a file with the following content
```
1 Hello World!
2 Hello World!
3 Hello World!
```
And we place the cursor over the `Hello`, start the replace method and change it to `Goodbye`, we end up with 
```
1 Goodbye World!
2 Goodbye World!
3 Goodbye World!
```
On the other hand, if we start with 
```
1 
2 Hello World!
3 Hello World!
4 Hello World!
```
and do the same replacement, we good
```
1 
2 Goodbye World!
3 Goodbye World!
4 Goodbye World!
```


## Know Yuse 

### Installation 
To build the prompt, we use [plenary](https://github.com/nvim-lua/plenary.nvim), so make sure to require it.

#### Packer
```lua
use {
        'dHuberYoumans/cmdy',
        requires={ {'nvim-lua/plenary.nvim' } },
    }
```

#### Our remaps
Keeping things simple, we remap those keys we want to put in focus. We chose to use to define a dedicated `cmdy.lua` in the standard location `~y/.config/nvim/after/plugin`
```lua
local cmdy = require('cmdy')
vim.keymap.set('n', ':', function() cmdy.focus_normal_mode() end)
vim.keymap.set('n', '/', function() cmdy.focus_search() end)
vim.keymap.set('n', '<leader>r', function() cmdy.focus_replace() end)
vim.keymap.set('n', '<leader>bs', function() cmdy.focus_buffers() end)
```

## Nuff Ced 

From here on there be dragons 🐲




