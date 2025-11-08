#! /usr/bin/env fish

# Set aliases for some programs in this repo

# Automatically determine the base dir
set base (dirname (realpath (status --current-filename)))

alias :adv="$base/games/adv.fish"
alias :fishfinder="cd ($base/fishfinder/finder.fish)"
alias :ff="cd ($base/fishfinder/finder.fish)"
alias :tbox="$base/tbox/tbox.fish"
alias :fishfish="$base/fishfish/fish.fish"
alias :reel="$base/reel/reel.fish"

echo set aliases:
alias | grep ':'
echo (set_color yellow)Note: these aliases are prefixed with a colon \(:\) to avoid conflicts with existing commands.(set_color normal)
