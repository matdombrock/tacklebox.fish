set -l base (dirname (realpath (status --current-filename)))
add_cmd angler "fish finder: file explorer" "$base/fishfinder/finder.fish)"
add_cmd angler "tbox: command launcher" "$base/fishfish/fish.fish"
add_cmd angler "reel: fuzzy find and install packages" "$base/reel/reel.fish fish"
add_cmd angler "fish: in fish" "$base/fishfish/fish.fish"
add_cmd angler "adventure game" "$base/games/adv.fish"
