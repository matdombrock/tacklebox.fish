# Ideas

! Aquarium

# Snippets

## Source a file in a relative directory
```sh
source (dirname (realpath (status --current-filename)))/../_lib/input.fish
```

## Ensure a program is installed
```sh
# Check for fzf
if not type -q fzf
    echo "This program requires 'fzf'!" && exit 1
end
```

## Fallback to a default program
```sh
set file_viewer cat
if type -q bat
    set file_viewer 'bat --plain --color=always'
else if type -q batcat # Some systems (e.g. Debian) use batcat instead of bat
    set file_viewer 'batcat --plain --color=always'
end
```
