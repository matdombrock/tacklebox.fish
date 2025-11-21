# LLM

A fish interface for interacting with LLMs.

![screenshot](_doc/screenshot.png)

## Supports

- Ollama
- More later?

## Config

This app looks for 2 environmental variables:
- `LLM_MODEL ` - The model you want to use
- `LLM_SERVER` - The server (with port) you want to use

## Usage

### Syntax
```sh
./llm.fish [cmd] [prompt ...]
```

### Example
```sh
./llm.fish com tell me a joke
```

### Commands
- `models` - List models
- `com   ` - A simple one-time completion
- `cmd   ` - Describe a unix command and the LLM will respond with a command example
- `chat  ` - Enter a chat with the LLM

> [!TIP]
> You will need to wrap your prompt in parenthesis if it contains reserved characters like (`?`). 

## Core

You can use the LLM wrappers direcly with `llm.core.fish`.

```sh
source llm.core.fish

# Make a completion request
set -l opts \
    prompt="Your prompt" \
    system="You are a helpful AI assistant." \
    model="gemma3:4b" \
    server="http://localhost:11434"
ollama_completion $opts

# Make a chat request
set -l opts \
    system="You are a helpful AI assistant." \
    model="gemma3:4b" \
    server="http://localhost:11434" \
    messages="[{\"role\":\"user\",\"content\":\"user message\"}]"
ollama_chat $opts
```
