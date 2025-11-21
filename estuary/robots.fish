#! /usr/bin/env fish

source (dirname (realpath (status --current-filename)))/../_lib/graph.fish
source (dirname (realpath (status --current-filename)))/../_lib/input.fish

set frame (graph.frame_new 10 10 | string collect)
set frame (graph.frame_set 1 1 g $frame | string collect)
set frame (graph.frame_set 10 10 g $frame | string collect)
graph.render $frame
