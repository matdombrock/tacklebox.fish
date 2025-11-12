# FishFinder

FishFinder is a terminal file explorer with fuzzy searching using fzf.

![screenshot](_doc/screenshot.png)

## Requires
- `fzf` 
- `../_lib/input.fish` 

> [!TIP]
> This tool will try to use `bat` or `batcat` to preview files if installed. If neither can be found it falls back to `cat`.

## Parameters
You can enter a special mode by sending an argument to fishfinder
- `no argument`: Normal mode, shows files and directories
- `explode, e `: Shows all files recursively from current directory
- `last, l    `: Last path mode, echoes the last selected path from fishfinder and exits
- `minimal, m `: Dont show TUI options (keybinds only mode)

> [!TIP]
> These parameters can be combined and passed in any order.

> [!TIP]
> When this program exists it will write a temporary file that contains the last selected path.
> You can retrieve this path with `fishfinder l`:
> ```sh
> fishfinder
> cd (fishfinder l)
> ```

## Keybinds
- `enter     `: Enter diretory or select file
- `right     `: Enter directory or select file
- `left      `: Go up one directory (cd ..)
- `ctrl-x    `: Toggle explode mode (show all files recursively from current directory)
- `ctrl-v    `: View file or directory listing
- `ctrl-p    `: Print the selected file path and exit
- `ctrl-g    `: Go to a directory (cd)
- `ctrl-l    `: Go back a directory (cd -)
- `ctrl-e    `: Execute the selected file
- `ctrl-o    `: Open file or directory in GUI (open / xdg-open) 
- `ctrl-y    `: Copy the selected path to the system clipboard
- `ctrl-d    `: Delete the selected file or directory with confirmation
- `alt-d     `: Instantly delete the selected file or directory
- `ctrl-r    `: Reload the current directory listing
- `: (colon) `: Execute a custom command on the selected file
- `shift-up  `: Scroll preview up
- `shift-down`: Scroll preview down
- `ctrl-q    `: Quit

## Todo
- Easy custom keybinds

