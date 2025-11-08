# angler.fish

A collection of (mostly) disconnected small `fish` shell programs for avid anglers.

## Aliases

You can add aliases for most of the useful programs here by running:

```sh
source angler.fish
```

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
