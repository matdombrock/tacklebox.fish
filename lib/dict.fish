# A small dictionary implementation for Fish
# All dict.* functions can be used independently
# Dictionaries look like this:
# set -l dict1 name=Alice age=30 city=Paris

# Get value by key
function dict.get
    set -l key $argv[1]
    set -l dict $argv[2..-1]
    for pair in $dict
        set -l k (string split '=' $pair)[1]
        set -l v (string split '=' $pair)[2]
        if test $k = $key
            echo $v
            return 0
        end
    end
    echo null
    return 1
end

# Set value by key
function dict.set
    set -l key $argv[1]
    set -l value $argv[2]
    set -l dict $argv[3..-1]
    set -l new_dict
    set -l found 0
    for pair in $dict
        set -l k (string split '=' $pair)[1]
        set -l v (string split '=' $pair)[2]
        if test $k = $key
            set new_dict $new_dict "$key=$value"
            set found 1
        else
            set new_dict $new_dict "$k=$v"
        end
    end
    if test $found -eq 0
        set new_dict $new_dict "$key=$value"
    end
    for item in $new_dict
        echo -e $item
    end
end

# Remove a key
function dict.remove
    set -l key $argv[1]
    set -l dict $argv[2..-1]
    set -l new_dict
    for pair in $dict
        set -l k (string split '=' $pair)[1]
        set -l v (string split '=' $pair)[2]
        if test $k != $key
            set new_dict $new_dict "$k=$v"
        end
    end
    for item in $new_dict
        echo $item
    end
end

# Get all keys, one per line
# NOTE: Fish expects lists to be returned as multiple lines
function dict.keys
    set -l dict $argv[1..-1]
    for pair in $dict
        set -l k (string split '=' $pair)[1]
        echo $k
    end
end

# Get all values, one per line
# NOTE: Fish expects lists to be returned as multiple lines
function dict.values
    set -l dict $argv[1..-1]
    for pair in $dict
        set -l v (string split '=' $pair)[2]
        echo $v
    end
end

# Expand a dictionary string into a list
# For example "alice=alice smol bart=bart simpson charlie=charlie brown" becomes: 
# alice=alice smol
# bart=bart simpson
# charlie=charlie brown
# NOTE: Fish expects lists to be returned as multiple lines
function dict.expand
    set -l words (string split ' ' $argv)
    set -l pair ""
    for word in $words
        if string match -qr '=' -- $word
            if test -n "$pair"
                echo $pair
            end
            set pair $word
        else
            set pair "$pair $word"
        end
    end
    if test -n "$pair"
        echo $pair
    end
end

# Pretty print the dictionary
function dict.pretty
    set -l dict $argv[1..-1]
    for pair in $dict
        set -l k (string split '=' $pair)[1]
        set -l v (string split '=' $pair)[2]
        set_color --bold green
        echo -n "$k"
        set_color cyan
        echo -n ": "
        set_color yellow
        echo "$v"
        set_color normal
    end
end

# Appease the LSP
# This code never runs
# Just avoids "function is not used" warnings
if test 0 = 1
    dict.get
    dict.set
    dict.remove
    dict.keys
    dict.values
    dict.expand
    dict.pretty
end
