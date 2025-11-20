#! /usr/bin/env fish

# Run tbox with angler commands
set -l base (dirname (realpath (status --current-filename)))
TBOX_CMD_PATH=$base/angler.cmds.fish $base/tbox/tbox.fish
