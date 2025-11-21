# Vest

Vest is a "curated history" fuzzy finder. It is not really history but a list
of commands of your choosing. Localized. It is like you're the winner of a war
and can write your own history.

## Config

The config should be in `.vest` and look like this:

```
Graph Log: git log --oneline --graph --decorate --all
Commit WIP :git commit -am "wip"
Nuke All :docker system prune -a --volumes
Enter Container: docker exec -it (docker ps -q | fzf) /bin/bash
Get Pods: kubectl get pods --all-namespaces
Describe Pod: kubectl describe pod
Update System: sudo apt update && sudo apt upgrade -y
```

The format is one entry per row, and each row has three fields separated by `: `.

1. Friendly name
2. Command

You can sprinkle `.vest` files all over your file system, and vest will pick
them up much like `git` picks up `.gitconfig`, adding up commands as it
traverses upwards.

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
