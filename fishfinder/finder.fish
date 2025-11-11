#! /usr/bin/env fish

#
# FishFinder is a terminal file explorer using fzf for selection and previewing files.
#

# Special keybindings in fzf:
# - Right Arrow: Enter directory or select file
# - Left Arrow: Go up one directory
# - Ctrl-V: View file or directory listing and exit
# - Ctrl-P: Print the selected file path and exit
# - Ctrl-E: Execute the selected file if it is executable and exit
# - Ctrl-D: Delete the selected file or directory with confirmation and reload
# - Alt-D:  Delete the selected file or directory with confirmation and reload
# - Ctrl-R: Reload the current directory listing
# - Ctrl-X: Toggle explode mode (show all files recursively from current directory)
# - : (colon): Execute a custom command on the selected file

# TODO:
# - More file operations: copy, move etc
# - Operation for `xdg-open` for viewing files with default applications
# - Operation to execute a command on the selected file (maybe map `:` to this?, use {} as file placeholder)
# - Option to execute with args, maybe should be the default for exec?
#   Could drop to > [cmd] ...
# - Its not possible to automatically cd the parent session into the selected directory
#   You can do something like `cd (fishfinder)` from the shell but that breaks editing files
#   You can also source this file which allows both cd and editing

source (dirname (realpath (status --current-filename)))/../lib/input.fish

function fishfinder
    # Check for fzf
    if not type -q fzf
        echo "This program requires `fzf`!" && exit 1
    end

    # Define special messages
    # NOTE: If the icons dont show, you need to use a nerd font in your terminal
    set exit_msg ' exit'
    set home_msg ' home'
    set up_msg ' .. up'
    set explode_msg ' explode'
    set unexplode_msg ' unexplode'

    # Passing functions from our script into fzf is tricky
    # The easiest way is to define them as strings and eval them inside fzf
    set lsx_string '\
function lsx
    # Since these vars should not be global, we must pass them as args
    set explode_mode $argv[1]
    set_color yellow
    echo '$exit_msg'
    if test "$explode_mode" = explode
        set_color yellow
        echo '$unexplode_msg'
        set_color normal
        echo
        find (pwd) -type f 2>/dev/null | sed "s|^$(pwd)/||"
        return
    end
    set_color yellow
    echo '$home_msg'
    echo '$explode_msg'
    set_color green
    echo '$up_msg'
    set_color normal
    echo
    ls --group-directories-first -A1 -F --color=always 2>/dev/null
end'
    # We also use the `lsx` function outside of fzf
    # We can use eval to define it as a literal function `lsx` the current context
    eval $lsx_string

    # Set the fzf preview command
    # Force this to use fish or it will use the default shell which may not be fish
    # This could also be done by just writing it as posix sh
    set file_viewer cat
    if type -q bat
        set file_viewer 'bat --plain --color=always'
    end
    set fzf_preview '\
fish -c "
# Since we use the -F flag on ls we might have a trailing asterisk
# For some reason (???) setting vars doesnt work here so we use a function instead
function clean_sel
  echo {} | sed \'s/[*\/]$//\'
end
if test -f (clean_sel); 
    echo (set_color --bold bryellow)file(set_color normal):
    '$file_viewer' (clean_sel); 
else if test -d (clean_sel); 
    echo (set_color --bold brred)directory(set_color normal):
    ls -A (clean_sel); 
else; 
    echo \"Not a file or directory\"; 
end
"'

    # We use a temp file to handle special exit commands
    set special_exit_path /tmp/ff_special_exit

    # Set up fzf options
    set fzf_options "--prompt=$(prompt_pwd)/" --ansi --layout=reverse --height=80% --border \
        --preview="$fzf_preview {}" --preview-window=right:60%:wrap \
        --bind=right:"accept" \
        --bind=ctrl-x:"reload(fish -c '$lsx_string; lsx explode')" \
        --bind=left:"execute(echo 'up:' >> $special_exit_path)+abort" \
        --bind=ctrl-v:"execute(echo view:{} >> $special_exit_path)+abort" \
        --bind=ctrl-p:"execute(echo print:{} >> $special_exit_path)+abort" \
        --bind=ctrl-e:"execute(echo exec:{} >> $special_exit_path)+abort" \
        --bind=ctrl-d:"execute(echo del:{} >> $special_exit_path)+abort" \
        --bind=alt-d:"execute(rm -rf {})+reload(fish -c '$lsx_string; lsx')" \
        --bind=ctrl-r:"reload(fish -c '$lsx_string; lsx')" \
        --bind=\::"execute(echo cmd:{} >> $special_exit_path)+abort"

    # Ask if we want to keep finding
    function keep_finding
        echo
        set confirm (input.char (set_color brcyan)">>> Keep finding? (y/n): ")
        if test $confirm = y
            fishfinder
        else
            echo (pwd)
        end
    end

    # Get the selection
    rm -f $special_exit_path
    set sel (lsx $argv[1] | fzf $fzf_options)

    # Check if a special exit command was written
    # If so, read it to $sel and delete the file
    if test -f $special_exit_path
        set sel (cat $special_exit_path)
        rm -f $special_exit_path
    end

    # Since we use the -F flag on ls we might have a trailing asterisk
    set sel (echo $sel | sed 's/[*\/]$//')

    #
    # Check for special exit commands
    #

    # Move up directory
    if test (string match "up:*" $sel)
        cd ..
        fishfinder
        return
    end

    # Just view the file / directory
    if test (string match "view:*" $sel)
        set sel (string replace "view:" "" $sel)
        if test -d "$sel"
            # This is a directory
            ls -A $sel
            keep_finding
            return
        else if test -f $sel
            set fv_cmd (string split ' ' $file_viewer)
            $fv_cmd $sel
            keep_finding
            return
        else
            # The user has likely selected a meta option by mistake
            fishfinder
            return

        end
    end

    # Just print the file path
    if test (string match "print:*" $sel)
        set sel (string replace "print:" "" $sel)
        echo $sel
        return
    end

    # Execute the file if executable
    if test (string match "exec:*" $sel)
        set sel (string replace "exec:" "" $sel)
        if test -x $sel
            ./$sel
        else
            echo "$sel is not executable."
        end
        keep_finding
        return
    end

    # Delete the file
    if test (string match "del:*" $sel)
        set sel (string replace "del:" "" $sel)
        set confirm (input.char "delete $sel? (y/n): ")
        if test $confirm = y
            echo "Deleting $sel ..."
            rm -rf $sel
            fishfinder
            return
        else
            echo "Aborting delete."
            fishfinder
            return
        end
    end

    # Execute command on file
    if test (string match "cmd:*" $sel)
        set sel (string replace "cmd:" "" $sel)
        set_color cyan
        echo "Enter command (use \$p as placeholder for '$sel'):"
        set cmd (input.line "> " | string replace -a \$p $sel)
        set_color bryellow
        echo "> $cmd"
        set_color normal
        eval $cmd
        keep_finding
        return
    end

    #
    # Handle normal commands
    #

    # Check if sel is null or empty
    if test -z "$sel"
        echo (pwd)
        return
    end

    # Handle exit
    if test "$sel" = "$exit_msg"
        echo (pwd)
        return
    end

    # Handle home directory
    if test "$sel" = "$home_msg"
        cd ~
        fishfinder
        return
    end

    # Handle up directory
    if test "$sel" = "$up_msg"
        cd ..
        fishfinder
        return
    end

    # Handle explode
    if test "$sel" = "$explode_msg"
        fishfinder explode
    end

    # Handle unexplode
    if test "$sel" = "$unexplode_msg"
        fishfinder
    end

    #
    # Handle file or directory
    #

    if test -d "$sel"
        # This is a directory
        cd $sel
        fishfinder
        return
    else if test -f $sel
        # This is a file
        if set -q VISUAL
            echo "Opening file with VISUAL editor: $VISUAL"
            $VISUAL $sel
            keep_finding
            return
        else if set -q EDITOR
            echo "Opening file with EDITOR: $EDITOR"
            $EDITOR $sel
            keep_finding
            return
        else
            echo "No editor set. Opening file with 'less'."
            less $sel
            keep_finding
            return
        end
    end
end

# Run FishFinder if the script is being executed directly
if not test "$_" = source
    fishfinder
end
