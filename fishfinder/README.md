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
- `hidden, h  `: Show hidden files

> [!TIP]
> These parameters can be combined and passed in any order.

> [!TIP]
> When this program exists it will write a temporary file that contains the last selected path.
> You can retrieve this path with `fishfinder l`:
> ```sh
> fishfinder
> cd (fishfinder l)
> ```

## Default Keybinds

- `enter     `: Enter diretory or select file
- `right     `: Enter directory or select file
- `left      `: Go up one directory (cd ..)
- `ctrl-a    `: Show all files (toggle hidden)
- `ctrl-x    `: Set explode mode (show all files recursively from current directory)
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
- `: (colon) `: Execute a custom command on the selected file or directory
- `shift-up  `: Scroll preview up
- `shift-down`: Scroll preview down
- `ctrl-q    `: Quit

## Custom Keybinds

You can set a `FF_KB` environmental variable with a path to a `keybinds.fish` file.

This file should contain a set of `kb` commands with this syntax:
```fish
kb [action] [key]
```

For example:
```sh
kb goto ctrl-d
```

### Action Map

- `accept  `: Accept the input
- `abort   `: Abort the input
- `up      `: Move up one dir (cd ..)
- `explode `: Set explode mode (show all files recursively from current directory)
- `view    `: Just view the file
- `goto    `: Go to a specific directory
- `last    `: Go to the last directory (cd -)
- `print   `: Print the selected file path and exit
- `exec    `: Execute the selected file
- `open    `: Open file or directory in GUI (open / xdg-open)
- `copy    `: Copy the selected path to the system clipboard
- `del     `: Delete the selected file or directory with confirmation
- `delquick`: Instantly delete the selected file or directory
- `realod  `: Reload the current directory listing
- `cmd     `: Execute a custom command on the selected file or directory
- `hidden  `: Toggle showing hidden files

> [!TIP]
> See the ['./keybinds.fish'](./keybinds.fish) file for keybind examples. 

> [!TIP]
> See [fzf man page](https://www.mankier.com/1/fzf#Key/Event_Bindings-Available_Keys:_(Synonyms)) for a list of valid keys.

## Todo
- Toggle hidden files
