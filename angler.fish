#! /usr/bin/env fish

if test "$_" = source
    # Set aliases for some programs in this repo
    # Automatically determine the base dir
    set -l base (dirname (realpath (status --current-filename)))

    # Adventure game
    alias :adv="$base/games/adv.fish"
    # Launch FishFinder (fuzzy file explorer)
    alias :fishfinder="$base/fishfinder/finder.fish"
    alias :ff="$base/fishfinder/finder.fish"
    # Launch fish finder and go to the final dir
    alias :ffg=":ff && cd ($base/fishfinder/finder.fish l)"
    # Demo TackleBox
    alias :tbox="$base/tbox/tbox.fish"
    # Fish in Fish
    alias :fishfish="$base/fishfish/fish.fish"
    # Launch Reel (fuzzy package manager)
    alias :reel="sudo $base/reel/reel.fish"

    echo set aliases:
    alias | grep ':'
    echo (set_color yellow)Note: these aliases are prefixed with a colon \(:\) to avoid conflicts with existing commands.(set_color normal)
else
    # Run tbox with angler commands
    set -l base (dirname (realpath (status --current-filename)))
    TBOX_CMD_PATH=$base/angler.cmds.fish $base/tbox/tbox.fish
end
