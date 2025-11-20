#! /usr/bin/env fish

source (dirname (realpath (status --current-filename)))/../_lib/input.fish
source (dirname (realpath (status --current-filename)))/llm.core.fish

set model gemma3:4b
set server http://localhost:11434

# Check if llm.cfg.fish exists in the user's config directory
set config_file ~/.config/fish/llm.cfg.fish
if test -f $config_file
    source $config_file
else
    echo -e "set model gemma3:4b\nset server http://localhost:11434" >>$config_file
    echo "Created default config file at:"
    echo $config_file
    set_color yellow
    echo "Please edit it to set your preferred model and server."
    exit 1
end

#
# Utility functions
#

function sysinfo
    echo -n $(whoami)@$(hostname) - \
        $(cat /etc/*-release | \
        grep PRETTY_NAME | \
        sed -e 's/PRETTY_NAME=//' -e 's/"//g')
    echo -n " | Kernel: " (uname -r)
    echo -n " | CPU: " (lscpu | grep "Model name" | sed -e 's/Model name:[ \t]*//')
    echo -n " | Memory: " (free -h | grep "Mem:" | awk '{print $2}')
    echo -n " | Disk: " (lsblk -d -o NAME,SIZE | grep -v NAME | awk '{print $1 ": " $2}')
    echo -n " | Uptime: " (uptime -p)
    echo -n " | Shell: " $SHELL
end

function echollm
    set -l opt $argv
    set -l res (ollama_completion $opt)
    set_color brgreen
    echo -e $res | string trim
end

#
# Command functions
#

function com
    set -l opts \
        prompt="$argv" \
        system="You are a helpful AI assistant." \
        model="$model" \
        server="$server"
    echollm $opts
end

function cmd
    set -l opts \
        prompt="$argv" \
        system="\
The user will describe a unix command.\
You will respond only with the requested command.\
Your response will be executed directly in their terminal.\
Here is the users system information: $(sysinfo)." \
        model="$model" \
        server="$server" \
        temperature=0.2
    echollm $opts
end

function chat
    # Initialize chat_history for this session
    set -l chat_history ""

    while true
        set -l user_message (input.line "> ")
        if test "$user_message" = /exit; or test "$user_message" = /quit
            break
        end

        if test -z "$user_message"
            continue
        end

        if test "$user_message" = /history
            if test -z "$chat_history"
                set_color yellow
                echo "No chat history yet."
            else
                set_color cyan
                echo -e "Chat History:\n[$chat_history]" | string trim
            end
            continue
        end

        # Append user message to history
        if test -z "$chat_history"
            set chat_history "{\"role\":\"user\",\"content\":\"$user_message\"}"
        else
            set chat_history $chat_history ",{\"role\":\"user\",\"content\":\"$user_message\"}"
        end

        # Format messages as JSON array
        set -l messages "[$chat_history]"

        set -l opts \
            model="$model" \
            server="$server" \
            system="You are a helpful AI assistant." \
            messages="$messages"
        # set -e opts
        # set -l opts (dict.set model $model $opts)
        # set -l opts (dict.set server $server $opts)
        # set -l opts (dict.set system "You are a helpful AI assistant." $opts)
        # set -l opts (dict.set messages "$messages" $opts)

        # echo $opts

        set -l res (ollama_chat $opts | string collect)

        set_color brgreen
        echo ""
        echo -e $res | string trim
        echo ""

        set -l res (echo $res | string join \n) # no new lines

        # Append AI response to history
        set chat_history $chat_history ",{\"role\":\"assistant\",\"content\":\"$res\"}"
    end
end

if test -z "$argv"
    echo "Usage: llm <command> [args...]"
    echo "Commands:"
    echo "  com <prompt>         Get a completion for the given prompt."
    echo "  cmd <description>    Get a unix command for the given description."
    echo "  chat                 Start an interactive chat session."
    exit 1
end

eval $argv[1] $argv[2..-1]
