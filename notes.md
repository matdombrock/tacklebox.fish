# Ideas

! Aquarium

# Snippets

## Source a file in a relative directory
```fish
source (dirname (realpath (status --current-filename)))/../_lib/input.fish
```

## Ensure a program is installed
```fish
# Check for fzf
if not type -q fzf
    echo "This program requires 'fzf'!" && exit 1
end
```

## Fallback to a default program
```fish
set file_viewer cat
if type -q bat
    set file_viewer 'bat --plain --color=always'
else if type -q batcat # Some systems (e.g. Debian) use batcat instead of bat
    set file_viewer 'batcat --plain --color=always'
end
```

## Variable scope in nested functions
In Fish shell, variables are local to the function where they are defined unless explicitly made global or universal. There is no concept of "lexical scoping" for nested functions—each function gets its own scope, and inner functions cannot access variables from their parent function unless those variables are global, universal, or explicitly passed.

```fish
function x
    set y "Hello, World!"
    function z
        echo $y
    end
    z
end
x
```

Here, `z` cannot access `y` because `y` is local to `x`, and Fish does not support closure-like scoping.

## Automatically create a config file
```fish
# Check if llm.cfg.fish exists in the user's config directory
set config_file ~/.config/fish/llm.cfg.fish
if test -f $config_file
    source $config_file
else
    echo -e "set model gemma3:4b\nset server http://localhost:11434" >>$config_file
    echo "Created default config file at:"
    echo $config_file
    set_color yellow
    echo "Please edit it to set your preferred model and server."
    exit 1
end
```
