#! /usr/bin/env fish

source (dirname (realpath (status --current-filename)))/../_lib/dict.fish
# Helper function to get option or default value
function opt_or
    set -l key $argv[1]
    set -l default $argv[2]
    set -l option $argv[3..-1]
    set -l value (dict.get $key $option)
    if test $value = null; or test $value = ""
        if test $default = exit
            echo "Error: $key is required" >&2
            exit 1
        end
        echo $default
    else
        echo $value
    end
end
