# Install packages using dnf with fuzzy search via fzf.

set query $argv

# Check for fzf
if not type -q fzf
    echo "This program requires `fzf`!" && exit 1
end

set fzf_opts --height=80% --layout=reverse --border --ansi

function fuzzy_pacman
    function install
        pacman -S $argv
    end
    function search
        pacman -Ss $argv | sed -e 's/    /-/g' -e '/^-/d'
    end
    function filter
        echo $argv | string split '.' | string split ' '
    end
    set search_res (search $argv | fzf $fzf_opts | string trim)
    if test -z "$search_res"
        echo "No package selected!" && exit 1
    end
    install (filter (string split \t $search_res))[1]
end

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
