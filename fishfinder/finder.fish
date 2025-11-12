#! /usr/bin/env fish

#
# FishFinder is a terminal file explorer with fuzzy searching using fzf.
#

source (dirname (realpath (status --current-filename)))/../_lib/input.fish
source (dirname (realpath (status --current-filename)))/../_lib/dict.fish

# We use a temp file to handle special exit commands
set special_exit_path /tmp/ff_special_exit
# NOTE: Some systems may not have /tmp so use $TMPDIR if set
if test -d "$TMPDIR"
    set special_exit_path $TMPDIR/ff_special_exit
end

# A function for setting up custom keybinds
# Must exist out of the main loop to avoid reloading on recursion
set ff_kb
function kb
    set -l action_id $argv[1]
    set -l input $argv[2]
    set -l action ''
    function spec
        set -l cmd $argv[1]
        echo "execute(echo $cmd >> $special_exit_path)+abort"
    end
    if test $action_id = accept
        set action accept
    else if test $action_id = abort
        set action abort
    else if test $action_id = up
        set action (spec "up:")
    else if test $action_id = explode
        set action (spec "explode:")
    else if test $action_id = view
        set action (spec "view:{}")
    else if test $action_id = goto
        set action (spec "goto:")
    else if test $action_id = last
        set action (spec "last:")
    else if test $action_id = print
        set action (spec "print:{}")
    else if test $action_id = exec
        set action (spec "exec:{}")
    else if test $action_id = open
        set action (spec "open:{}")
    else if test $action_id = copy
        set action (spec "copy:{}")
    else if test $action_id = del
        set action (spec "del:{}")
    else if test $action_id = delquick
        set action (spec "delquick:{}")
    else if test $action_id = reload
        set action (spec "reload:")
    else if test $action_id = cmd
        set action (spec "cmd:{}")
    else if test $action_id = hidden
        set action (spec "hidden:")
    end
    set ff_kb $ff_kb --bind="$input:$action"
end

# Check if we have an FF_KB environment variable
# If so, load keybinds from there
set ff_kb_path (dirname (realpath (status --current-filename)))/keybinds.fish
if test -n "$FF_KB"
    set ff_kb_path $FF_KB
end
# Load keybinds
source $ff_kb_path

function fishfinder

    # Parse arguments, flags is a `dict` type
    set flags explode=false minimal=false last=false
    for arg in $argv
        if test "$arg" = explode; or test "$arg" = e
            set flags (dict.set explode true $flags)
        else if test "$arg" = minimal; or test "$arg" = m
            set flags (dict.set minimal true $flags)
        else if test "$arg" = last; or test "$arg" = l
            set flags (dict.set last true $flags)
        else if test "$arg" = hidden; or test "$arg" = h
            set flags (dict.set hidden true $flags)
        end
    end
    # If argv is a dict, use that instead
    if test (count $argv) -ge 1
        if test (string match -r '^[^=]+=.*' $argv[1])
            set flags $argv
        end
    end

    # Check for fzf
    if not type -q fzf
        echo "This program requires 'fzf'!" && exit 1
    end

    # Check fzf version
    # On old versions of fzf we cant use --with-shell
    # If fzf is less than 0.48 and shell is not fish, exit with error
    set fzf_version (fzf --version | string replace -r 'fzf v' '')
    set fzf_major_version (echo $fzf_version | string split '.' | head -n2)
    # We assume the user has fish as their default shell
    set fzf_with_shell false
    # If they dont have fish as their default shell, we need fzf >= 0.48
    if test $SHELL != /usr/bin/fish
        set fzf_with_shell true
        if test $fzf_major_version -lt 0.48
            echo "This program requires fzf version 0.39 or higher!"
            echo "You have version $fzf_version installed."
            echo "Either upgrade fzf or set fish as your default shell."
            exit 1
        end
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
        set -l flags $argv[2..-1]
        echo
        set -l confirm (input.char (set_color brcyan)">>> Keep finding? (Y/n): ")
        if test $confirm = y; or test $confirm = Y; or test $confirm = ''
            fishfinder $flags
        else
            write (pwd) $ff_lp_path
        end
    end

    # Echo if condition is false
    function echo_not
        set -l condition $argv[1]
        set -l msg $argv[2]
        if test $condition = false
            echo $msg
        end
    end

    # Create the list of files and directories used by fzf
    function lsx
        # Since these vars should not be global, we must pass them as args 
        set -l exit_str $argv[1]
        set -l goto_str $argv[2]
        set -l back_str $argv[3]
        set -l up_str $argv[4]
        set -l explode_str $argv[5]
        set -l unexplode_str $argv[6]
        set -l flags $argv[7..-1]
        set -l fl_explode (dict.get explode $flags)
        set -l fl_minimal (dict.get minimal $flags)
        set -l fl_hidden (dict.get hidden $flags)
        echo_not $fl_minimal "$(set_color -u brred)$exit_str"
        if test "$fl_explode" = true
            echo_not $fl_minimal "$(set_color -u bryellow)$unexplode_str"
            set_color normal
            find (pwd) -type f 2>/dev/null | sed "s|^$(pwd)/||"
            return
        end
        echo_not $fl_minimal "$(set_color -u bryellow)$explode_str"
        echo_not $fl_minimal "$(set_color -u brgreen)$goto_str"
        echo_not $fl_minimal "$(set_color -u brmagenta)$back_str"
        echo_not $fl_minimal "$(set_color -u brcyan)$up_str"
        set_color normal
        if test "$fl_hidden" = true
            ls --group-directories-first -A1 -F --color=always 2>/dev/null
        else
            ls --group-directories-first -I '.*' -A1 -F --color=always 2>/dev/null
        end
    end

    # Define special messages
    # NOTE: If the icons dont show, you need to use a nerd font in your terminal
    set exit_str ' exit'
    set goto_str '󰁕 goto'
    set back_str ' back'
    set up_str ' .. up'
    set explode_str ' explode'
    set unexplode_str ' unexplode'
    set cmd_str 'λ  '

    # Determine file viewer command
    set file_viewer cat
    if type -q bat
        set file_viewer 'bat --plain --color=always'
    else if type -q batcat # Some systems (e.g. Debian) use batcat instead of bat
        set file_viewer 'batcat --plain --color=always'
    end
    # Set the fzf preview command
    # NOTE: Passing functions from our script into fzf is tricky
    # The easiest way is to define them as strings and eval them inside fzf
    set fzf_preview_fn '\
function tip;
  echo (set_color brgreen) command(set_color normal):;
  echo (set_color bryellow)$argv(set_color normal);
end;
# Since we use the -F flag on ls we might have a trailing asterisk
set clean_sel (echo {} | string replace "*" "");
if test {} = "'$exit_str'"; 
    tip "Exit back to the shell"; 
else if test {} = "'$goto_str'"; 
    tip "Go to a directory (cd)"; 
else if test {} = "'$back_str'"; 
    tip "Go back to previous directory (cd -)";
else if test {} = "'$up_str'"; 
    tip "Go up one directory (cd ..)"; 
else if test {} = "'$explode_str'"; 
    tip "Explode current directory (find . -type f)"; 
else if test {} = "'$unexplode_str'"; 
    tip "Unexplode current directory";
else if test -f $clean_sel; 
    echo (set_color --bold bryellow) file(set_color normal):
    '$file_viewer' $clean_sel; 
else if test -d $clean_sel; 
    echo (set_color --bold brred)  directory(set_color normal):
    ls --group-directories-first -A1 -F --color=always $clean_sel 2>/dev/null; 
else if test -L $clean_sel; 
    echo (set_color --bold bryellow)symlink(set_color normal):
    ls -l --color=always $clean_sel 2>/dev/null;
else if test -e $clean_sel; 
    echo (set_color --bold bryellow)other(set_color normal):
    ls -l --color=always $clean_sel 2>/dev/null;
else if test -S $clean_sel; 
    echo (set_color --bold bryellow)socket(set_color normal):
    ls -l --color=always $clean_sel 2>/dev/null;
else if test -p $clean_sel; 
    echo (set_color --bold bryellow)pipe(set_color normal):
    ls -l --color=always $clean_sel 2>/dev/null;
else if test -b $clean_sel; 
    echo (set_color --bold bryellow)block device(set_color normal):
    ls -l --color=always $clean_sel 2>/dev/null;
else if test -c $clean_sel; 
    echo (set_color --bold bryellow)character device(set_color normal):
    ls -l --color=always $clean_sel 2>/dev/null;
else if test -d $clean_sel = false; and test -f $clean_sel = false; 
    echo (set_color --bold bryellow)non-standard file type(set_color normal):
    ls -l --color=always $clean_sel 2>/dev/null;
else; 
    echo No preview available.; 
end
'

    # Define path to ff_lp temp file
    set ff_lp_path /tmp/ff_lp
    # NOTE: Some systems may not have /tmp so use $TMPDIR if set
    if test -d "$TMPDIR"
        set ff_lp_path $TMPDIR/ff_lp
    end

    # Set up fzf options
    set fzf_options "--prompt=$(prompt_pwd)/" --ansi --layout=reverse --height=98% --border --preview="$fzf_preview_fn" --preview-window=right:60%:wrap

    # If we need to specify shell for fzf, do so
    if test $fzf_with_shell = true
        set fzf_options $fzf_options --with-shell "fish -c"
    end

    # Attach keybinds
    set fzf_options $fzf_options $ff_kb

    #
    # Start the main logic
    #

    # If we have 'flags.last' just echo last path and exit
    if test "$(dict.get last $flags)" = true
        if test -f $ff_lp_path
            cat $ff_lp_path
        end
        return
    end

    # Clean up any previous special exit command
    # Guards against false positives
    rm -f $special_exit_path

    # Draw the header area
    clear
    set width (tput cols)
    set art_width 20
    set padding (math floor (math "($width - $art_width) / 2"))
    set bg \~ # ░
    set_color brmagenta
    for i in (seq $padding)
        echo -n $bg
    end
    echo -n (set_color yellow)"/ "
    echo -n (set_color brwhite)"||"
    echo -n (set_color brblue)" FishFinder "
    echo -n (set_color brwhite)"||"
    echo -n (set_color yellow)" \\"(set_color normal)
    set_color brgreen
    for i in (seq $padding)
        echo -n $bg
    end
    # Check if we have an odd number of columns
    set diff (math $width - $art_width - (math $padding x 2))
    if test $diff != 0
        for i in (seq $diff)
            echo -n $bg
        end
    end
    echo

    # Get the selection
    set sel (lsx \
      $exit_str \
      $goto_str \
      $back_str \
      $up_str \
      $explode_str \
      $unexplode_str \
      $flags \
      | fzf $fzf_options)

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
    # The commands here are only accessible via keybinds in fzf
    #

    # Handle view: Just view the file / directory
    if test (string match "view:*" $sel)
        set sel (string replace "view:" "" $sel)
        if test -d "$sel"
            # This is a directory
            ls -l -A $sel
            keep_finding $ff_lp_path $flags
            return
        else if test -f $sel
            set fv_cmd (string split ' ' $file_viewer)
            $fv_cmd $sel
            keep_finding $ff_lp_path $flags
            return
        else
            # The user has likely selected a meta option by mistake
            fishfinder $flags
            return
        end
    end

    # Handle print: Just print the file path
    if test (string match "print:*" $sel)
        set sel (string replace "print:" "" $sel)
        # if $sel is not file or dir use pwd
        if not test -f $sel; and not test -d $sel
            set sel (pwd)
        end
        set full_dir (echo (pwd)/$sel)
        echo $full_dir
        write $full_dir $ff_lp_path
        return
    end

    # Handle exec: Execute the file if executable
    if test (string match "exec:*" $sel)
        set sel (string replace "exec:" "" $sel)
        if test -x $sel
            ./$sel
        else
            echo "$sel is not executable."
            keep_finding $ff_lp_path $flags
            return
        end
        fishfinder $flags
        return
    end

    # Handle del: Delete the file
    if test (string match "del:*" $sel)
        set sel (string replace "del:" "" $sel)
        set confirm (input.char "delete $sel? (y/n): ")
        if test $confirm = y
            echo "Deleting $sel ..."
            rm -rf $sel
            fishfinder $flags
            return
        else
            echo "Aborting delete."
            fishfinder $flags
            return
        end
    end

    # Handle delquick: Delete the file without confirmation
    if test (string match "delquick:*" $sel)
        set sel (string replace "delquick:" "" $sel)
        rm -rf $sel
        fishfinder $flags
        return
    end

    # Handle cmd: Execute command on file
    if test (string match "cmd:*" $sel)
        set sel (string replace "cmd:" "" $sel)
        # if $sel is not file or dir use pwd
        if not test -f $sel; and not test -d $sel
            set sel (pwd)
        end
        set_color bryellow
        echo "$cmd_str# Send 'b', 'back' or '' to return to fishfinder"
        echo "$cmd_str# Sending 'exit' will return to the parent shell"
        set_color cyan
        echo "$cmd_str""\$p = $sel"
        set cmd init
        set exit_cmds q quit back b ''
        while not contains $cmd $exit_cmds
            set cmd (input.line $cmd_str | string replace -a \$p $sel)
            set_color bryellow
            echo "$cmd_str""$cmd"
            set_color normal
            eval $cmd
        end
        fishfinder $flags
        return
    end

    # Handle hidden: Toggle hidden files
    if test $sel = "hidden:"
        set fl_hidden (dict.get hidden $flags)
        if test "$fl_hidden" = true
            set flags (dict.set hidden false $flags)
        else
            set flags (dict.set hidden true $flags)
        end
        fishfinder $flags
        return
    end

    # Handle open: Open file with default application
    if test (string match "open:*" $sel)
        set sel (string replace "open:" "" $sel)
        # Ensure file or directory exists
        if not test -e $sel
            set sel (pwd)
        end
        # Open using xdg-open (Linux) or open (macOS)
        if type -q xdg-open
            xdg-open $sel >/dev/null 2>&1 &
        else if type -q open
            open $sel >/dev/null 2>&1 &
        else
            echo "No suitable open command found (xdg-open or open)."
            keep_finding $ff_lp_path $flags
            return
        end
        fishfinder $flags
        return
    end

    # Handle copy: Copy file path to clipboard
    if test (string match "copy:*" $sel)
        set sel (string replace "copy:" "" $sel)
        # Ensure file or directory exists
        if not test -e $sel
            set sel (pwd)
        end
        set full_path (realpath $sel)
        # Copy to clipboard using pbcopy (macOS), xclip (X11), or
        # wl-copy (Wayland)
        if type -q pbcopy
            echo -n $full_path | pbcopy
        else if type -q xclip
            echo -n $full_path | xclip -selection clipboard
        else if type -q wl-copy
            echo -n $full_path | wl-copy
        else
            echo "No suitable clipboard command found (pbcopy, xclip, or wl-copy)."
            keep_finding $ff_lp_path $flags
            return
        end
        echo "Copied to clipboard: $full_path"
        keep_finding $ff_lp_path (dict.get explode $flags) (dict.get minimal $flags)
        return
    end

    # Handle reload: Reload fishfinder
    if test (string match "reload:*" $sel)
        # Always reload without exploding
        set flags (dict.set explode false $flags)
        fishfinder $flags
        return
    end

    #
    # Handle normal commands
    # These may also be accessible via keybinds in fzf
    #

    # Handle exit
    if test "$sel" = "$exit_str"
        write (pwd) $ff_lp_path
        return
    end

    # Handle goto directory
    # Handles 'goto:' as well
    if test $sel = $goto_str; or test $sel = "goto:"
        echo "Enter path to go to:"
        set goto_path (input.line $cmd_str)
        # Handle home shortcut
        if test "$goto_path" = "~"
            set goto_path $HOME
        end
        set goto_path (realpath $goto_path)
        # Validate path
        while not test -d "$goto_path"
            echo "Directory does not exist: $goto_path"
            echo "Enter path to go to:"
            set goto_path (input.line $cmd_str)
        end
        cd $goto_path
        fishfinder $flags
        return
    end

    # Handle up directory
    if test "$sel" = "$up_str"; or test "$sel" = "up:"
        cd ..
        fishfinder $flags
        return
    end

    # Handle last: Just go back to fishfinder
    if test "$sel" = "$back_str"; or test "$sel" = "last:"
        cd -
        fishfinder $flags
        return
    end

    # Handle explode
    if test "$sel" = "$explode_str"; or test "$sel" = "explode:"
        set flags (dict.set explode true $flags)
        fishfinder $flags
    end

    # Handle unexplode
    if test "$sel" = "$unexplode_str"
        set flags (dict.set explode false $flags)
        fishfinder $flags
    end

    #
    # Handle file or directory
    #

    if test -d "$sel"
        # This is a directory
        cd $sel
        fishfinder $flags
        return
    else if test -f $sel
        # This is a file
        if set -q VISUAL
            echo "Opening file with VISUAL editor: $VISUAL"
            $VISUAL $sel
            fishfinder $flags
            return
        else if set -q EDITOR
            echo "Opening file with EDITOR: $EDITOR"
            $EDITOR $sel
            fishfinder $flags
            return
        else
            echo "No editor set. Opening file with 'less'."
            less $sel
            fishfinder $flags
            return
        end
    end
end

# Run FishFinder if the script is being executed directly
if not test "$_" = source
    fishfinder $argv
end
