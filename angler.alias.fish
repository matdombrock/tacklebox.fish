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
function _angler_alias
    if test -z "$argv"
        echo -e $_angler_alias_help_text
        return
    end
    set -l desc $argv[1]
    set -l name $argv[2]
    set -l cmd $argv[3]
    set -a _angler_alias_help_text "$(set_color brgreen)$name - $(set_color bryellow)$desc \n"
    alias $name=$cmd
end

_angler_alias "Create an angler style alias, list with no input" :alias _angler_alias

:alias "Reload fish config" :rlfish "source ~/.config/fish/config.fish"
:alias "Reload angler aliases" :rlangler "source $base/angler.alias.fish"
:alias "Update angler repo" :upangler "cd $base && git pull && echo \$(set_color green)'Angler updated!'"
:alias "Angler TackleBox" :angler "$base/angler.fish"
:alias "FishFinder fuzzy file explorer" :fishfinder "$base/fishfinder/finder.fish"
:alias "FishFinder fuzzy file explorer" :ff "$base/fishfinder/finder.fish"
:alias "Run FishFinder and cd to the selected directory" :ffg ":ff && cd ($base/fishfinder/finder.fish l)"
:alias "TackleBox command launcher" :tbox "$base/tbox/tbox.fish"
:alias "Fish in Fish" :fishfish "$base/fishfish/fish.fish"
:alias "Reel fuzzy package manager" :reel "$base/reel/reel.fish"
:alias "Quick git commit helper" :fgit "$base/fgit/fgit.fish"
:alias "Manage fish shell prompt styles" :rod _rod
:alias "Interact with LLMs" :llm "$base/llm/llm.fish"
:alias "Adventure game" :adv "$base/games/adv.fish"
:alias "Graphical Dice Roller" :dice "$base/games/dice.fish"
:alias "SHARKS! game" :sharkz "$base/games/sharkz.fish"
