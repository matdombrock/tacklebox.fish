function choose_vest_command
    set -l cmd_file ~/.config/fish/vest_commands.txt
    set -l sep " : "

    # --- STEP 1: SELECT CATEGORY ---
    set -l category (grep -v "^#" $cmd_file | awk -F "$sep" '{print $1}' | sort -u | \
        fzf --header "Select Category" --reverse)

    if test -z "$category"
        commandline -f repaint
        return
    end

    # --- STEP 2: SELECT COMMAND ---
    # 1. Filter by category
    # 2. awk constructs the line:
    #    Column 1 (Visible): Description + Space + (Gray Color) Command (Reset Color)
    #    Column 2 (Hidden):  Valid Tab Character + Raw Command (no colors)
    set -l selection (grep "^$category$sep" $cmd_file | \
        awk -F "$sep" '{printf "%s \033[90m%s\033[0m\t%s\n", $2, $3, $3}' | \
        fzf --ansi --delimiter "\t" --with-nth 1 --header "Select Command ($category)" --reverse --no-hscroll)

    if test -n "$selection"
        # Split the result by the Tab character
        # The Clean Command is in the 2nd index
        set -l cmd (string split \t $selection)[2]
        
        commandline -r $cmd
    end

    commandline -f repaint
end
