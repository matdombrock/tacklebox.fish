# Requires jq

source (dirname (realpath (status --current-filename)))/../_lib/dict.fish

function opt_or
    set -l key $argv[1]
    set -l default $argv[2]
    set -l opt $argv[3..-1]
    set -l value (dict.get $key $opt)
    if test $value = null
        if test $default = exit
            echo "Error: $key is required" >&2
            exit 1
        end
        echo $default
    else
        echo $value
    end
end

function ollama
    set -l opt $argv

    set -l prompt (opt_or prompt exit $opt)
    set -l model (opt_or model exit $opt)
    set -l server (opt_or server "http://localhost:11434" $opt)
    set -l system (opt_or system "You are a helpful assistant" $opt)
    set -l seed (opt_or seed -1 $opt)
    set -l temperature (opt_or temperature 0.7 $opt)

    set -l res (\
curl -s $server/api/generate \
  -d '{
  "model": "'$model'",
  "prompt": "'$prompt'",
  "system": "'$system'",
  "options": {
    "seed": '$seed',
    "temperature": '$temperature'
  },
  "stream": false
}')

    echo $res | jq -r '.response'
end

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
    set -l res (ollama $opt)
    set_color brgreen
    echo $res | string trim
end

function com
    set -l opt \
        prompt="$argv" \
        system="You are a helpful AI assistant." \
        model="$model" \
        server="$server"
    echollm $opt
end

function cmd
    set -l opt \
        prompt="$argv" \
        system="\
The user will describe a unix command.\
You will respond only with the requested command.\
Your response will be executed directly in their terminal.\
Here is the users system information: $(sysinfo)." \
        model="$model" \
        server="$server" \
        temperature=0.2
    echollm $opt
end

eval $argv[1] $argv[2..-1]

# Appease LSP
if test 1 = 0
    ollama
    com
    cmd
end
