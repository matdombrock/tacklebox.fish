# FishFinder

FishFinder is a terminal file explorer with fuzzy searching using fzf.

![screenshot](_doc/screenshot.png)

## Requires
- `fzf` 
- `../lib/input.fish` 

> [!TIP]
> This tool will try to use `bat` or `batcat` to preview files if installed. If neither can be found it falls back to `cat`.

## Modes:
You can enter a special mode by sending an argument to fishfinder
- No argument: Normal mode, shows files and directories
- `explode`: Shows all files recursively from current directory
- `l`: Last path mode, echoes the last selected path from fishfinder and exits

> [!TIP]
> When this program exists it will write a temporary file that contains the last selected path.
> You can retrieve this path with `fishfinder l`:
> ```sh
> fishfinder
> cd (fishfinder l)
> ```

## Keybinds:
- Right Arrow: Enter directory or select file
- Left Arrow: Go up one directory
- Ctrl-V: View file or directory listing
- Ctrl-P: Print the selected file path and exit
- Ctrl-E: Execute the selected file
- Ctrl-X: Toggle explode mode (show all files recursively from current directory)
- Ctrl-D: Delete the selected file or directory with confirmation
- Alt-D:  Instantly delete the selected file or directory
- Ctrl-R: Reload the current directory listing
- : (colon): Execute a custom command on the selected file
- Shift-Up Arrow: Scroll preview up
- Shift-Down Arrow: Scroll preview down
- CTRL-Q: Quit

## Goals
- More file operations: copy, move etc
- Operation for `xdg-open` for viewing files with default applications
    - Should also support `open` for macOS
- Option to execute with args, maybe should be the default for exec?
    - Could drop to > [cmd] ...
- Goto command to jump to a specific directory
    - Maybe replace the 'home' option
- This is becoming hard to maintain
    - It may be easier if implemented in a way that cant be sourced cleanly
    - In other words, not as a single top level function

