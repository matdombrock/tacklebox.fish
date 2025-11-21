function choose_vest_command
    set -l temp_file (mktemp)

    # Check for fzf
    if not type -q fzf
        echo "This program requires 'fzf'!" && exit 1
    end

    # Start from current directory
    set -l current_dir (pwd)
    set -l home_dir $HOME

    # Collect commands from .vest files in current and parent directories
    while true
        set -l vest_file "$current_dir/.vest"

        # If .vest exists and is readable, append its commands
        if test -f "$vest_file" -a -r "$vest_file"
            grep -v "^#" "$vest_file" | grep -v "^[[:space:]]*\$" >> $temp_file
        end

        # Stop if we've reached home directory or root
        if test "$current_dir" = "$home_dir" -o "$current_dir" = "/"
            break
        end

        # Move to parent directory
        set -l parent_dir (dirname "$current_dir")

        # If we can't access parent, stop
        if not test -r "$parent_dir"
            break
        end

        set current_dir $parent_dir
    end

    # Check if we found any commands
    if not test -s $temp_file
        echo "No .vest files found"
        rm $temp_file
        commandline -f repaint
        return
    end

    # Format and select command
    # Split only on first ": " occurrence
    set -l selection (awk '{
        colon_pos = index($0, ": ")
        if (colon_pos > 0) {
            name = substr($0, 1, colon_pos - 1)
            cmd = substr($0, colon_pos + 2)
            printf "%s \033[90m%s\033[0m\t%s\n", name, cmd, cmd
        }
    }' $temp_file | \
        fzf --ansi --delimiter "\t" --with-nth 1 --header "Select Command" --reverse --no-hscroll)

    rm $temp_file

    if test -n "$selection"
        # Extract command (after tab)
        set -l cmd (string split \t $selection)[2]
        commandline -r $cmd
    end

    commandline -f repaint
end
