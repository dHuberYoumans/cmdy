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
* allow custom color configurations for the prompts
* buffer ls: on <CR> navigate directly to the buffer, don't just close search prompt and jump into buffer ls (then need to hit <CR> again) -> bad UX
* buffer ls: allow to enter buffer ls using arrow keys (see telescope etc)

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
vim.keymap.set('n', '/', function() cmdy.focus_search() end)
vim.keymap.set('n', '<leader>r', function() cmdy.focus_replace() end)
vim.keymap.set('n', '<leader>bs', function() cmdy.focus_buffers() end)
```

## Mostly Harmless

### config.lua

If you like to change the appearences of the prompts or the window listing the buffers, you can do so directly in `init.lua` by defining a table `my_config` and calling 
```config.setup({my_config})```.

The layout of `my_config` must be as follows:
```lua
my_config = {
    -- prompt character
    cmdline = {
        prompt =
    },
    -- buffer window layout
    buffers = {
        buffer_window = {
            title = 
            line = 
            col = 
            width = 
            minheight = 
            maxheight =
            borderchars =
        },
        buffer_window_prompt = {
            title =
            width =
            row =
            col =
        }
    }
    -- search prompt
    search = {
        title = 
    }
}
```
Where, at the moment, we allow the following prompt symbols (which can be easily expanded in `config.lua`)
```lua
config.prompt_symbols = {
    ["$"] = true,
    ["λ"] = true,
    ["/"] = true,
    ["❯"] = true,
    [">"] = true,
}
```
Our default options are 
```lua
defaults = {
    -- prompt character
    cmdline = {
        prompt = "❯",
    },
    -- buffer window layout
    buffers = {
        buffer_window = {
        title = "BUFFER LIST",
        line = blsw_row,
        col = blsw_col,
        width = blsw_width,
        minheight = blsw_height - gap,
        maxheight = blsw_height - gap,
        borderchars = borderchars,
    },
    buffer_window_prompt = {
        title = '',
        width = blsw_width,
        row =  blsw_prompt_row,
        col = blsw_col,
    }
    -- search prompt
    search = {
        title = "SEARCH"
    }
}```
where we use the following standard layout values for
```lua
    -- buffer list window (blsw)
    local blsw_width = math.floor(vim.o.columns * 0.75)
    local blsw_height = math.floor(vim.o.lines * 0.75)
    local blsw_row = 3
    local blsw_col = math.floor((vim.o.columns - blsw_width)/2)
    local blsw_prompt_row = blsw_row + blsw_height
```

### Through the looking glass: cmdline
Since autocompletion is too important, and to keep whatever is left of our sanity, we decided to let (neo)vim handle all autocompletion. 
We thus simply mirror the command line. Typing in normal mode is thus magnified, so to speak. The advantage of it that we get the full power of vim's cmdline. The disadvantage is that one might need selective vision or at least selective focus (since we will see the input displayed and changed in two places as one). 

## Nuff Ced 

From here on there be dragons 🐲




