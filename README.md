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
| display of buffer list | floating search prompt | floating normal prompt | 
| ----- | ----- | ----- |
| <img width="330" alt="focused-buffer" src="https://github.com/user-attachments/assets/0a39c801-2916-4e9b-83d3-360c2fa7218f" /> |  <img width="330" alt="focused-search" src="https://github.com/user-attachments/assets/612ec3bf-c799-4a7f-b9fc-1b7b6f8c03fd" /> |  <img width="330" alt="focused-normal-mode" src="https://github.com/user-attachments/assets/067d6a05-83ee-41d3-b367-a25e27a68304" /> |

## WIP 

* dynamic resizing of prompt buffers 

## A bug's life 🐛

### replace-all

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

### autocompletion

When both, the prompt and autocompletion's suggestions window are open, `<ESC>` will close the prompt, leaving the window ith the suggestions open - one has to hit `<ESC>` again. To properly close the window of suggestions, use `<C-e>` 

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

## Mostly Harmless

### config.lua

If you like to change the appearences of the prompts or the window listing the buffers, you can edit the `config.lua` file. 
Our default options are 
```lua
-- prompt defaults
M.prompt_defaults = {
    title = "NORMAL MODE",
    width = math.floor(vim.o.columns * 0.75),
    line = math.floor(vim.o.lines / 2),
    col = math.floor((vim.o.columns - math.floor(vim.o.columns * 0.75)) / 2),
    height = 1,
    borderchars = borderchars,
}

-- buffer list window (blsw)
local blsw_width = math.floor(vim.o.columns * 0.75)
local blsw_height = math.floor(vim.o.lines * 0.75)
local blsw_row = 3
local blsw_col = math.floor((vim.o.columns - blsw_width)/2)
local blsw_prompt_row = blsw_row + blsw_height

M.buffer_window = {
    title = "BUFFER LIST",
    line = blsw_row,
    col = blsw_col,
    width = blsw_width,
    minheight = blsw_height - gap,
    maxheight = blsw_height - gap,
    borderchars = borderchars,
}
```

### autocompletion

Were we not to use prompt buffers, we could rely on better plugins for autocompletion like [nvim-cmp](https://github.com/hrsh7th/nvim-cmp). However, we are trying to mimic the autocompletion of the cmdline, and that in a minimalistic way.

For autocompletion inside the prompt buffer, we are using `vim.fn.getcompletion`. To get the correct context, like `cmdline`, `option` or `file` we filter the prompt input. Based on the prefix, we decide for the context. For exmaple, when we have an empty prompt, by default, we set the context to `cmdline`, since we expect the user to enter a command. When the user starts typing and hits `<TAB>` (which will trigger the autocmpletion) we still set the context to `cmdline`. However, if the user hits `<TAB>` after having typed the first command, we will set the context as follows:

* `set` -> `option`
* `e, edit, vsplit, hsplit, source` -> `file` 

We will update the prefix logic and decisions gradually as we go along.

As said before, `<TAB>` will trigger the autocompletion. Once the suggestions are shown in a new window, we can choose between them with the standard keys: `<C-n>` for the next, `<C-p>` for the previous suggestion. We confirm a choice with `<CR>` (Enter)  To close the window of suggestions, use `<C-e>`.

## Nuff Ced 

From here on there be dragons 🐲




