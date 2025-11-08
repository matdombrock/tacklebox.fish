#! /usr/bin/env fish

source ../lib/dict.fish

# Check for fzf
if not type -q fzf
    echo "This program requires `fzf`!"
    echo "Please install it and try again."
    exit 1
end

set query_str $argv

set back_str " back"
set fzf_opts --height=80% --layout=reverse --border --ansi

set cmds
set categories ""
function add_cmd
    set category $argv[1]
    set desc $argv[2]
    set cmd $argv[3]
    if test $categories = ""
        set categories $category
    else if not string match -q "*$category*" $categories
        set categories "$categories||$category"
    end
    set new (set_color yellow)$desc' | '(set_color green)$cmd
    set cur (dict.get $category $cmds)
    set comb
    if test $cur = null
        set comb $new
    else
        set comb "$cur||$new"
    end
    set cmds (dict.set $category $comb $cmds)
end

function expand_categories
    set keys (string split '||' $categories)
    echo all
    for key in $keys
        echo $key
    end
end

function expand_cmds
    set category $argv[1]
    set_color red
    echo $back_str
    # All category
    if test $category = all
        set keys (string split '||' $categories)
        for key in $keys
            set data (dict.get $key $cmds)
            set data (string split '||' $data)
            for cmd in $data
                echo $cmd
            end
        end
        return
    end
    # Normal category
    set data (dict.get $category $cmds)
    set data (string split '||' $data)
    for cmd in $data
        echo $cmd
    end
end

set cmd_path finder_commands.fish
# Check if we have a FF_COMMANDS_PATH env var
if set -q FF_CMD_PATH
    echo overriding command path with $FF_CMD_PATH
    set cmd_path $FF_CMD_PATH
end
# Check if command file exists
if test -f $cmd_path
    # echo "Loading commands from $cmd_path"
else
    echo "Command file $cmd_path not found!"
    exit 1
end
source $cmd_path

function run
    set cat_str

    # If we have a prefilled command query, skip category selection
    if test -n "$query_str"
        set cat_str all
        # If we have only one category, skip category selection
    else if test (count (string split '||' $categories)) -eq 1
        set cat_str (string split '||' $categories)[1]
    else
        set cat_str (expand_categories | fzf $fzf_opts --prompt="$(set_color blue)category > ")
        if test -z "$cat_str"
            exit 1
        end
    end

    set cmd_str (expand_cmds $cat_str | fzf --query=$query_str $fzf_opts --prompt="$(set_color green)$cat_str/$(set_color blue)command > " --preview 'echo {}' --preview-window down:5:hidden:wrap --bind '?:toggle-preview')

    if test -z "$cmd_str"
        exit 1
    end

    # check for back
    # NOTE: We could reset the query_str here if we wanted to
    if test $cmd_str = $back_str
        run
    end

    set cmd (string split ' | ' $cmd_str)[2]

    # Handle required arguments
    while string match -q '*{##}*' $cmd
        set_color yellow
        echo λ $cmd
        set arg
        while test -z "$arg"
            read -P "##: " arg
            if test $status -ne 0
                exit 0
            end
        end
        set cmd (string replace '{##}' $arg $cmd)
        set_color normal
    end
    # Handle optional arguments
    while string match -q '*{#}*' $cmd
        set_color yellow
        echo λ $cmd
        read -P "#: " arg
        if test $status -ne 0
            exit 0
        end
        set cmd (string replace '{#}' $arg $cmd)
        set_color normal
    end
    # Handle explodes
    # NOTE: These are the same as optional args
    # Its just syntactic sugar for the user
    while string match -q '*{...}*' $cmd
        set_color yellow
        echo λ $cmd
        read -P "...: " arg
        if test $status -ne 0
            exit 0
        end
        set cmd (string replace '{...}' $arg $cmd)
        set_color normal
    end

    set_color yellow
    echo λ $cmd

    eval $cmd
end

if not set -q FF_NO_HEADER; or test $FF_NO_HEADER != 1
    echo "\
$(set_color blue   )▗▄▄▄▖▗▄▄▄▖ ▗▄▄▖▗▖ ▗▖$(set_color green )▗▄▄▄▖▗▄▄▄▖▗▖  ▗▖▗▄▄▄  ▗▄▄▄▖▗▄▄▖ 
$(set_color magenta)▐▌     █  ▐▌   ▐▌ ▐▌$(set_color yellow)▐▌     █  ▐▛▚▖▐▌▐▌  █ ▐▌   ▐▌ ▐▌
$(set_color magenta)▐▛▀▀▘  █   ▝▀▚▖▐▛▀▜▌$(set_color yellow)▐▛▀▀▘  █  ▐▌ ▝▜▌▐▌  █ ▐▛▀▀▘▐▛▀▚▖
$(set_color blue   )▐▌   ▗▄█▄▖▗▄▄▞▘▐▌ ▐▌$(set_color green )▐▌   ▗▄█▄▖▐▌  ▐▌▐▙▄▄▀ ▐▙▄▄▖▐▌ ▐▌
" | string replace -a ' ' \~
end

run
