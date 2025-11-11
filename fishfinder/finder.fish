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

# TODO:
# - If the file is executable, offer to run it vs edit it.
# - Its not possible to leave the shell in the final dir
#   You can do something like `cd (fishfinder)` from the shell but that breaks editing files
#   You can also source this file which allows both cd and editing

source (dirname (realpath (status --current-filename)))/../lib/input.fish

function fishfinder
    # Check for fzf
    if not type -q fzf
        echo "This program requires `fzf`!" && exit 1
    end

    # Define special messages
    set exit_msg '📁 exit'
    set home_msg '~/'
    set up_msg '.. up'

    # Passing functions from our script into fzf is tricky
    # The easiest way is to define them as strings and eval them inside fzf
    set lsx_string '\
function lsx
    # Since these vars should not be global, we must pass them as args
    set exit_msg $argv[1]
    set home_msg $argv[2]
    set up_msg $argv[3]
    set_color yellow
    echo $exit_msg
    echo $home_msg
    set_color green
    echo $up_msg
    set_color normal
    ls --group-directories-first -A1
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
    set fzf_preview 'fish -c "
    if test -f {}; 
        echo (set_color --bold bryellow)file(set_color normal):
        '$file_viewer' {}; 
    else if test -d {}; 
        echo (set_color --bold brred)directory(set_color normal):
        ls -A {}; 
    else; 
        echo \"Not a file or directory\"; 
    end
"'

    # We use a temp file to handle special exit commands
    set special_exit_path /tmp/ff_special_exit

    # Set up fzf options
    # We can make a full lsx string to reload the listing
    set lsx_string_full "$lsx_string && lsx \"$exit_msg\" \"$home_msg\" \"$up_msg\""
    set fzf_options "--prompt=$(prompt_pwd)/" --ansi --layout=reverse --height=80% --border \
        --preview="$fzf_preview {}" --preview-window=right:60%:wrap \
        --bind=right:"accept" \
        --bind=left:"execute(echo 'up:' >> $special_exit_path)+abort" \
        --bind=ctrl-v:"execute(echo view:{} >> $special_exit_path)+abort" \
        --bind=ctrl-p:"execute(echo print:{} >> $special_exit_path)+abort" \
        --bind=ctrl-e:"execute(echo exec:{} >> $special_exit_path)+abort" \
        --bind=ctrl-d:"execute(echo del:{} >> $special_exit_path)+abort" \
        --bind=alt-d:"execute(rm -rf {})+reload($lsx_string_full)" \
        --bind=ctrl-r:"reload($lsx_string_full)"

    function keep_finding
        set confirm (input.char (set_color bryellow)"Keep finding? (y/n): ")
        if test $confirm = y
            fishfinder
        else
            echo (pwd)
        end
    end

    # Get the selection
    rm -f $special_exit_path
    set sel (lsx $exit_msg $home_msg $up_msg | fzf $fzf_options)

    # Check if a special exit command was written
    # If so, read it to $sel and delete the file
    if test -f $special_exit_path
        set sel (cat $special_exit_path)
        rm -f $special_exit_path
    end
    # Check if we got a special exit command
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
        end
        set fv_cmd (string split ' ' $file_viewer)
        $fv_cmd $sel
        keep_finding
        return
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

    # Handle file or directory
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
