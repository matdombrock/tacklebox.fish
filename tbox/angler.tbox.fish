set -l base (dirname (realpath (status --current-filename)))
add_cmd angler "FishFinder: file explorer" "$base/fishfinder/finder.fish"
add_cmd angler "Tbox: command launcher" "set TBOX_CMD_PATH $base/tbox/demo.tbox.fish && $base/tbox/tbox.fish"
add_cmd angler "Reel: fuzzy find and install packages" "$base/reel/reel.fish fish"
add_cmd angler "Fish: in fish" "$base/fishfish/fish.fish"
add_cmd angler "adventure game" "$base/games/adv.fish"
