# [angler](https://en.wikipedia.org/wiki/Angling).[fish](https://en.wikipedia.org/wiki/Anglerfish)

A collection of (mostly) disconnected small `fish` shell programs for avid anglers.

![angler fish](_doc/anglerfish.png)
> Image: Average fish user

## Programs

### [FishFinder](/fishfinder)
TUI file explorer
### [FishFish](/fishfish)
Fish in fish
### [Games](/games)
Games written in fish
### [Reel](/reel)
Fuzzy package manager
### [TackleBox](/tbox)
TUI fuzzy finding launcher

## Demo

Use `tbox` to load a TUI that can launch these programs:
```sh
./angler.fish
```

## Aliases

You can add aliases for most of the useful programs here by running:

```sh
source angler.alias.fish
```

> [!TIP]
> Use the `:alias` alias to list all angler aliases.
> 
> You can also use `:alias` to set new angler style aliases


> [!WARNING]
> You must be inside a `fish` shell to source these aliases.

### Sourcing vs Alias

You use most tools in three ways.

Set an alias:

```sh
alias mytool='bash /path/to/mytool.sh'
```

Or to have them source a function like:

```sh
source /path/to/mytool.sh
```

You may also add them to `$PATH` and call them directly.

> [!WARNING]
> It's **recommended to make an alias** since sourcing some scripts may pollute your shell with global functions and variables. 
