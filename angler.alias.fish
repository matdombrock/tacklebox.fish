#! /usr/bin/env fish

# Set aliases for some programs in this repo
# NOTE: 
# these aliases are prefixed with a colon \(:\) to avoid conflicts with existing commands.
#
# Usage:
# source ~/path/to/angler.fish/angler.alias.fish

# Automatically determine the base dir
set -l base (dirname (realpath (status --current-filename)))

#
# Sourced files
# 
# Some files need to be sourced to work properly
#
source $base/rod/rod.fish

# Helper to create aliases and build help text
set _angler_alias_help_text "$(set_color brblue)Available Angler aliases:\n"
function aalias
    set -l desc $argv[1]
    set -l name $argv[2]
    set -l cmd $argv[3]
    set -a _angler_alias_help_text "$(set_color brgreen)$name - $(set_color bryellow)$desc \n"
    alias $name=$cmd
end

aalias "List all Angler aliases" :alias "echo -e \$_angler_alias_help_text"
aalias "Angler TackleBox" :angler "$base/angler.fish"
aalias "FishFinder fuzzy file explorer" :fishfinder "$base/fishfinder/finder.fish"
aalias "FishFinder fuzzy file explorer" :ff "$base/fishfinder/finder.fish"
aalias "Run FishFinder and cd to the selected directory" :ffg ":ff && cd ($base/fishfinder/finder.fish l)"
aalias "TackleBox command launcher" :tbox "$base/tbox/tbox.fish"
aalias "Fish in Fish" :fishfish "$base/fishfish/fish.fish"
aalias "Reel fuzzy package manager" :reel "$base/reel/reel.fish"
aalias "Quick git commit helper" :fgit "$base/fgit/fgit.fish"
aalias "Manage fish shell prompt styles" :rod _rod
aalias "Adventure game" :adv "$base/games/adv.fish"
