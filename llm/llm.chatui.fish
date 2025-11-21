#! /usr/bin/env fish

source (dirname (realpath (status --current-filename)))/opt_or.fish
source (dirname (realpath (status --current-filename)))/llm.core.fish

# opts:
# model (required)
# system (default: You are a helpful AI assistant)
# server (default: http://localhost:11434)
# temperature (default: 0.7)
# seed (default: -1)
function chatui
    set -l opts $argv
    set -l model (opt_or model exit $opts)
    set -l system (opt_or system "You are a helpful AI assistant" $opts)
    set -l server (opt_or server "http://localhost:11434" $opts)
    set -l temperature (opt_or temperature 0.7 $opts)
    set -l seed (opt_or seed -1 $opts)

    set_color magenta
    echo "System: $system"
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
            set chat_history "{\"role\":\"system\",\"content\": \"$system\"},{\"role\":\"user\",\"content\":\"$user_message\"}"
        else
            set chat_history $chat_history ",{\"role\":\"user\",\"content\":\"$user_message\"}"
        end

        # Format messages as JSON array
        set -l messages "[$chat_history]"

        set -l opts \
            model="$model" \
            server="$server" \
            system="$system" \
            messages="$messages" \
            temperature="$temperature" \
            seed="$seed"

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
