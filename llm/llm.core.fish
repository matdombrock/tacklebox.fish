#! /usr/bin/env fish

# Requires jq

source (dirname (realpath (status --current-filename)))/../_lib/dict.fish
source (dirname (realpath (status --current-filename)))/opt_or.fish
# dict.delimiter "===DICT_DELIM==="

# opts:
# server (default: http://localhost:11434)
function ollama_list_models
    set -l opts $argv
    set -l server (opt_or server "http://localhost:11434" $opts)
    curl -s $server/api/tags
end

# opts:
# prompt (required)
# model (required)
# server (default: http://localhost:11434)
# system (default: You are a helpful assistant)
# seed (default: -1)
# temperature (default: 0.7)
function ollama_completion
    set -l opts $argv

    set -l prompt (opt_or prompt exit $opts)
    set -l model (opt_or model exit $opts)
    set -l server (opt_or server "http://localhost:11434" $opts)
    set -l system (opt_or system "You are a helpful assistant" $opts)
    set -l seed (opt_or seed -1 $opts)
    set -l temperature (opt_or temperature 0.7 $opts)

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

    set -l res (echo $res | jq -r '.response')
    echo -e $res
end

# opts:
# model (required)
# messages (required) - JSON array string
# server (default: http://localhost:11434)
# system (default: You are a helpful assistant)
# seed (default: -1)
# temperature (default: 0.7)
#
# messages should be a JSON array string, e.g. 
# '[{"role":"user","content":"Hello"}]'
function ollama_chat
    set -l opts $argv

    set -l model (opt_or model exit $opts)
    set -l messages (opt_or messages exit $opts)
    set -l server (opt_or server "http://localhost:11434" $opts)
    set -l system (opt_or system "You are a helpful assistant" $opts)
    set -l seed (opt_or seed -1 $opts)
    set -l temperature (opt_or temperature 0.7 $opts)

    set -l payload (string join '' '
    {
      "model": "'$model'",
      "messages": '$messages',
      "options": {
        "seed": '$seed',
        "temperature": '$temperature'
      },
      "stream": false
    }')
    curl -s $server/api/chat -d "$payload" | jq -r '.message.content'
end


