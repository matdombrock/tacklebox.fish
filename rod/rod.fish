#! /usr/bin/env fish

# NOTE: This file is intended to be sourced
# This is required to set the prompt style

set PROMPT default
set rod_list default minimal replicat

function fish_prompt
    # Check if PROMPT is in rod_list
    if not contains $PROMPT $rod_list
        set_color red
        echo "Warning: PROMPT '$PROMPT' not found in rod_list. Reverting to 'default'."
        rod # Call with no args to get the list
        set_color normal
        # We cant continue without  having some kind of prompt here
        set PROMPT default
    end
    source (dirname (realpath (status --current-filename)))/prompt/$PROMPT.fish
    _fish_prompt
    return
end

function _rod
    if test "$argv[1]" = list; or test "$argv[1]" = l; or test -z "$argv[1]"
        set_color brmagenta
        echo "Available prompt styles:"
        set_color brgreen
        for prompt_style in $rod_list
            echo " - $prompt_style"
        end
        return
    end
    set PROMPT $argv[1]
end

# Create alias for easier listing
alias :rod='_rod'

# Appease the LSP
if test 1 = 0
    fish_prompt
    _rod
end
