#! /usr/bin/env fish

if test "$_" = source
    # Set aliases for some programs in this repo
    # Automatically determine the base dir
    set -l base (dirname (realpath (status --current-filename)))

    alias :adv="$base/games/adv.fish"
    alias :fishfinder="$base/fishfinder/finder.fish"
    alias :ff="$base/fishfinder/finder.fish"
    alias :ffcd="$base/fishfinder/finder.fish" # Breaks editing
    alias :tbox="$base/tbox/tbox.fish"
    alias :fishfish="$base/fishfish/fish.fish"
    alias :reel="$base/reel/reel.fish"

    echo set aliases:
    alias | grep ':'
    echo (set_color yellow)Note: these aliases are prefixed with a colon \(:\) to avoid conflicts with existing commands.(set_color normal)
else
    # Run tbox with angler commands
    set -l base (dirname (realpath (status --current-filename)))
    TBOX_CMD_PATH=$base/angler.cmds.fish $base/tbox/tbox.fish
end
