#! /usr/bin/env fish

# Set aliases for some programs in this repo

# NOTE: these aliases are prefixed with a colon \(:\) to avoid conflicts with existing commands.

# Automatically determine the base dir
set -l base (dirname (realpath (status --current-filename)))

set helptext "$(set_color brblue)Available Angler aliases:\n"
function helpa
    set -l split (string split ' - ' $argv)
    set -a helptext "$(set_color brgreen)$split[1] - $(set_color bryellow)$split[2] \n"
end

# Sourced files
source $base/rod/rod.fish

# Adventure game
alias :adv="$base/games/adv.fish"
helpa ":adv - Launch the Adventure game."
# Launch FishFinder (fuzzy file explorer)
alias :fishfinder="$base/fishfinder/finder.fish"
helpa ":fishfinder - Launch the FishFinder fuzzy file explorer."
alias :ff="$base/fishfinder/finder.fish"
helpa ":ff - Launch the FishFinder fuzzy file explorer."
# Launch fish finder and go to the final dir
alias :ffg=":ff && cd ($base/fishfinder/finder.fish l)"
helpa ":ffg - Launch FishFinder and cd to the selected directory."
# Demo TackleBox
alias :tbox="$base/tbox/tbox.fish"
helpa ":tbox - Launch the TackleBox demo."
# Fish in Fish
alias :fishfish="$base/fishfish/fish.fish"
helpa ":fishfish - Launch Fish in Fish."
# Launch Reel (fuzzy package manager)
alias :reel="sudo $base/reel/reel.fish"
helpa ":reel - Launch the Reel fuzzy package manager."
# Quick git commits
alias :fgit="$base/fgit/fgit.fish"
helpa ":fgit - Quick git commit helper."
# Rod prompt manager
alias :rod="_rod"
helpa ":rod - Manage Rod prompt styles."
# Launch angler tbox
alias :angler="$base/angler.fish"
helpa ":angler - Launch the Angler TackleBox."
# List aliases
alias :alias="echo -e \$helptext"
helpa ":alias - List all Angler aliases."
