#!/usr/bin/env fish

source (dirname (realpath (status --current-filename)))/../_lib/input.fish

function section
    echo (set_color -r normal)" $argv"(set_color -r normal)" "
    set_color normal
end

section (set_color brcyan)"  BRANCH  "
set gbranch (git rev-parse --abbrev-ref HEAD 2>/dev/null)
if test -n "$gbranch"
    echo $gbranch
else
    echo Not a git repository
    exit 1
end

section (set_color bryellow)"  STATUS  "
set gstatus (git status -s)
if test (count $gstatus) -eq 0
    set_color green
    echo Clean
else
    git status -s
end

if test (count $argv) -eq 0
    section (set_color magenta)"  MESSAGE "
    echo "Enter commit message (empty to abort):"
    set msg (input.line "> ")
    if test -z "$msg"
        echo No commit message provided
        exit 1
    end
else
    set msg $argv
end

section (set_color brgreen)"  CONFIRM "
set_color green
echo $msg
set accept (input.char (set_color yellow)"Proceed with commit? (y/n): ")
if test "$accept" != y
    set_color red
    echo Commit aborted
    exit 1
end
git add .
git commit -m "$msg"
git push -u origin $gbranch

set_color green
echo --- COMPLETE ---
