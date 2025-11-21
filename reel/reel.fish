#! /usr/bin/env fish

# Install packages using dnf with fuzzy search via fzf.
# Never automatically installs the package

# The high-level process here is:
# 1) search - Search for a package and filter results onto one line.
#   Sometimes we also need to filter out extra metadata from the package manager
# 2) filter - Filter the selected package info down to just the name
# 3) install - Install the target package

# TODO: 
# - Add support for more package managers (e.g., yum, zypper, etc.)
# - Add an option to show package details before installation
# - Add an option to uninstall packages

# Check for fzf
if not type -q fzf
    echo "This program requires 'fzf'!" && exit 1
end

set fzf_opts --prompt="$(set_color cyan)reel in $(set_color bryellow)$argv$(set_color cyan): " --height=80% --layout=reverse --border --ansi

function fuzzy_pacman
    function search
        pacman -Ss $argv | sed -e 's/    /-/g' -e '/^-/d'
    end
    function filter
        echo $argv | string split '.' | string split ' '
    end
    function install
        echo λ(set_color yellow) pacman -S $argv(set_color normal)
        sudo pacman -S $argv
    end
    set search_res (search $argv | fzf $fzf_opts | string trim)
    if test -z "$search_res"
        echo "No package selected!" && exit 1
    end
    install (filter (string split \t $search_res))[1]
end

function fuzzy_apt
    function search
        apt search $argv | grep -E '^[a-zA-Z0-9]' | sed -e 's/ - /-/g' | tail -n +3
    end
    function filter
        echo $argv | string split '.' | string split ' '
    end
    function install
        echo λ(set_color yellow) apt install $argv(set_color normal)
        sudo apt install $argv
    end
    set search_res (search $argv | fzf $fzf_opts | string trim)
    if test -z "$search_res"
        echo "No package selected!" && exit 1
    end
    install (filter (string split '/' $search_res))[1]
end

function fuzzy_dnf
    function search
        dnf search $argv \
            | string replace -r 'Matched fields:.*' '' \
            | string trim \
            | string match -rv '^$'
    end
    function filter
        echo $argv | string split '.' | string split ' '
    end
    function install
        echo λ(set_color yellow) dnf install $argv(set_color normal)
        sudo dnf install $argv
    end
    set search_res (search $argv | fzf $fzf_opts | string trim)
    if test -z "$search_res"
        echo "No package selected!" && exit 1
    end
    install (filter (string split '.' $search_res))[1]
end

function reel
    set query $argv
    set mode
    if type -q pacman
        set mode fuzzy_pacman
    else if type -q apt
        set mode fuzzy_apt
    else if type -q dnf
        set mode fuzzy_dnf
    else
        echo "No supported package manager found!" && exit 1
    end
    $mode $query
end

if not test "$_" = source
    reel $argv
else
    functions --erase fuzzy_pacman
    functions --erase fuzzy_apt
    functions --erase fuzzy_dnf
    set -e fzf_opts
end
