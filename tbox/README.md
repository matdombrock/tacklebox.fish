# Tbox

Too many aliases and scripts to keep track of? 

Keep your less commonly used commands in tbox.

Sort them into categories and fuzzy find them as needed.

![screenshot](_doc/screenshot.png)

## Requires

- `fzf`
- `../_lib/dict.fish`

## Environmental variables:
```sh
TBOX_NO_HEADER=1 # Hide the logo
TBOX_CMD_PATH=~/my_commands.fish # Change the command path
```

## Usage
```sh
# Full interactive search
tbox.fish

# With a pre-filled query
tbox.fish "my query"
```

## Commands

Commands are defined like this:
```sh
add_cmd edit "edit nvim config" "cd ~/.config/nvim && nvim"
add_cmd edit "edit fish config" "cd ~/.config/fish && nvim"
add_cmd file "list all files in pwd" "ls -A"
```

> [!NOTE]
> The commands run in a new session. So things like changing directories (`cd`) and setting environmental variables work, but will not persist in the parent shell session.

### Command Syntax

```sh
add_cmd [category] [description] [command]
```

>[!TIP]
> If only one category is provided, the category selection is automatically skipped.

## Command Parameters

```sh
# Commands can take parameters
add_cmd test t1 "echo {##} {#}"
# Note that unlike aliases, parameters can go anywhere
add_cmd network "ssh local" "ssh $(whoami)@192.168.1.{#}"
```

### Parameter Types

- required `{##}`
- optional `{#}`
- exploded `{...}`

>[!NOTE]
> There is no functional difference between optional and exploded commands. All commands are exploded. The exploded parameter type is just a hint to the end user. 
> An optional or exploded parameter which is not given an argument will be set to an empty char ('').

