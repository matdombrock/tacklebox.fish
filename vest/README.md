# Vest

Vest is a curated history fuzzy finder. It is not really history but a list of
commands of your choosing.

# Config

The config should be in `~/.config/fish/vest_commands.txt` and look like this:

```
Git : Graph Log : git log --oneline --graph --decorate --all
Git : Commit WIP : git commit -am "wip"
Docker : Nuke All : docker system prune -a --volumes
Docker : Enter Container : docker exec -it (docker ps -q | fzf) /bin/bash
K8s : Get Pods : kubectl get pods --all-namespaces
K8s : Describe Pod : kubectl describe pod
MyUtils : Update System : sudo apt update && sudo apt upgrade -y
```

The format is one entry per row, and each row has three fields separated by ` : ` (with spaces).

1. Category
2. Friendly name
3. Command

## Requires

- `fzf`

## Config

Put this in your `config.fish`:

```fish
source ~/git/angler.fish/vest/vest.fish

function fish_user_key_bindings
    # Execute the 'choose_vest_command' function when Ctrl+O is pressed
    bind \co choose_vest_command
end
```

## Usage

Hit `Ctrl-O` and first select category, then the command. You can type to
filter with `fzf`. The command will be pasted in the command line.
