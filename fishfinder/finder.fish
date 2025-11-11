#! /usr/bin/env fish

#
# FishFinder is a terminal file explorer with fuzzy searching using fzf.
#

# TODO:
# - More file operations: copy, move etc
# - Operation for `xdg-open` for viewing files with default applications
# - Option to execute with args, maybe should be the default for exec?
#   Could drop to > [cmd] ...
# - This is becoming hard to maintain
#   It may be easier if implemented in a way that cant be sourced cleanly
#   In other words, not as a single top level function

source (dirname (realpath (status --current-filename)))/../_lib/input.fish

function fishfinder

    set mode $argv[1] # Optional mode argument

    # Check for fzf
    if not type -q fzf
        echo "This program requires `fzf`!" && exit 1
    end

    # Write data to path
    function write
        set -l data $argv[1]
        set -l path $argv[2]
        echo $data >$path
    end

    # Ask if we want to keep finding
    function keep_finding
        set -l ff_lp_path $argv[1]
        echo
        set -l confirm (input.char (set_color brcyan)">>> Keep finding? (Y/n): ")
        if test $confirm = y; or test $confirm = Y; or test $confirm = ''
            fishfinder
        else
            write (pwd) $ff_lp_path
        end
    end

    # Define special messages
    # NOTE: If the icons dont show, you need to use a nerd font in your terminal
    set exit_str ' exit'
    set home_str ' home'
    set up_str ' .. up'
    set explode_str ' explode'
    set unexplode_str ' unexplode'

    # NOTE: Passing functions from our script into fzf is tricky
    # The easiest way is to define them as strings and eval them inside fzf
    # Force string functions to use fish or it will use the default shell which may not be fish
    # This could also be done by just writing it as posix sh but this is a fish script after all
    set lsx_fn '\
function lsx
    # Since these vars should not be global, we must pass them as args
    set explode_mode $argv[1]
    set_color yellow
    echo '$exit_str'
    if test "$explode_mode" = explode
        set_color yellow
        echo '$unexplode_str'
        set_color normal
        echo
        find (pwd) -type f 2>/dev/null | sed "s|^$(pwd)/||"
        return
    end
    set_color yellow
    echo '$home_str'
    echo '$explode_str'
    set_color green
    echo '$up_str'
    set_color normal
    echo
    ls --group-directories-first -A1 -F --color=always 2>/dev/null
end'
    # We also use the `lsx` function outside of fzf
    # We can use eval to define it as a literal function `lsx` the current context
    eval $lsx_fn

    # Set the fzf preview command
    set file_viewer cat
    if type -q bat
        set file_viewer 'bat --plain --color=always'
    else if type -q batcat # Some systems (e.g. Debian) use batcat instead of bat
        set file_viewer 'batcat --plain --color=always'
    end
    set fzf_preview_fn '\
fish -c "
# Since we use the -F flag on ls we might have a trailing asterisk
# For some reason (???) setting vars doesnt work here so we use a function instead
function clean_sel
  echo {} | sed \'s/[*\/]\$//\'
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

    # Define path to ff_lp temp file
    set ff_lp_path /tmp/ff_lp
    # NOTE: Some systems may not have /tmp so use $TMPDIR if set
    if test -d "$TMPDIR"
        set ff_lp_path $TMPDIR/ff_lp
    end

    # We use a temp file to handle special exit commands
    set special_exit_path /tmp/ff_special_exit
    # NOTE: Some systems may not have /tmp so use $TMPDIR if set
    if test -d "$TMPDIR"
        set special_exit_path $TMPDIR/ff_special_exit
    end

    # Set up fzf options
    set fzf_options "--prompt=$(prompt_pwd)/" --ansi --layout=reverse --height=80% --border \
        --preview="$fzf_preview_fn {}" --preview-window=right:60%:wrap \
        --bind=right:"accept" \
        --bind=ctrl-x:"reload(fish -c '$lsx_fn; lsx explode')" \
        --bind=left:"execute(echo 'up:' >> $special_exit_path)+abort" \
        --bind=ctrl-v:"execute(echo view:{} >> $special_exit_path)+abort" \
        --bind=ctrl-p:"execute(echo print:{} >> $special_exit_path)+abort" \
        --bind=ctrl-e:"execute(echo exec:{} >> $special_exit_path)+abort" \
        --bind=ctrl-d:"execute(echo del:{} >> $special_exit_path)+abort" \
        --bind=alt-d:"execute(rm -rf {})+reload(fish -c '$lsx_fn; lsx')" \
        --bind=ctrl-r:"reload(fish -c '$lsx_fn; lsx')" \
        --bind=\::"execute(echo cmd:{} >> $special_exit_path)+abort"

    #
    # Start the main logic
    #

    # If we have 'l' mode just echo last path and exit
    if test "$mode" = l
        if test -f $ff_lp_path
            cat $ff_lp_path
        end
        return
    end

    # Clean up any previous special exit command
    # Guards against false positives
    rm -f $special_exit_path

    # Get the selection
    set sel (lsx $mode | fzf $fzf_options)

    # Check if a special exit command was written
    # If so, read it to $sel and delete the file
    if test -f $special_exit_path
        set sel (cat $special_exit_path)
        rm -f $special_exit_path
    end

    # Since we use the -F flag on ls we might have a trailing asterisk
    set sel (echo $sel | sed 's/[*\/]$//')

    # Check if sel is null or empty
    if test -z "$sel"
        write (pwd) $ff_lp_path
        return
    end

    #
    # Check for special exit commands
    #

    # Handle up: Move up directory
    if test (string match "up:*" $sel)
        cd ..
        fishfinder
        return
    end

    # Handle view: Just view the file / directory
    if test (string match "view:*" $sel)
        set sel (string replace "view:" "" $sel)
        if test -d "$sel"
            # This is a directory
            ls -l -A $sel
            keep_finding $ff_lp_path
            return
        else if test -f $sel
            set fv_cmd (string split ' ' $file_viewer)
            $fv_cmd $sel
            keep_finding $ff_lp_path
            return
        else
            # The user has likely selected a meta option by mistake
            fishfinder $ff_lp_path
            return
        end
    end

    # Handle print: Just print the file path
    if test (string match "print:*" $sel)
        set sel (string replace "print:" "" $sel)
        echo $sel
        write $sel $ff_lp_path
        return
    end

    # Handle exec: Execute the file if executable
    if test (string match "exec:*" $sel)
        set sel (string replace "exec:" "" $sel)
        if test -x $sel
            ./$sel
        else
            echo "$sel is not executable."
        end
        keep_finding $ff_lp_path
        return
    end

    # Handle del: Delete the file
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

    # Handle cmd: Execute command on file
    if test (string match "cmd:*" $sel)
        set sel (string replace "cmd:" "" $sel)
        set_color cyan
        echo "Enter command (use \$p as placeholder for '$sel'):"
        set cmd (input.line "> " | string replace -a \$p $sel)
        set_color bryellow
        echo "> $cmd"
        set_color normal
        eval $cmd
        keep_finding $ff_lp_path
        return
    end

    #
    # Handle normal commands
    #

    # Handle exit
    if test "$sel" = "$exit_str"
        write (pwd) $ff_lp_path
        return
    end

    # Handle home directory
    if test "$sel" = "$home_str"
        cd ~
        fishfinder
        return
    end

    # Handle up directory
    if test "$sel" = "$up_str"
        cd ..
        fishfinder
        return
    end

    # Handle explode
    if test "$sel" = "$explode_str"
        fishfinder explode
    end

    # Handle unexplode
    if test "$sel" = "$unexplode_str"
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
            keep_finding $ff_lp_path
            return
        else if set -q EDITOR
            echo "Opening file with EDITOR: $EDITOR"
            $EDITOR $sel
            keep_finding $ff_lp_path
            return
        else
            echo "No editor set. Opening file with 'less'."
            less $sel
            keep_finding $ff_lp_path
            return
        end
    end
end

# Run FishFinder if the script is being executed directly
if not test "$_" = source
    fishfinder $argv
end
