#! /usr/bin/env fish

source (dirname (realpath (status --current-filename)))/../_lib/graph.fish
source (dirname (realpath (status --current-filename)))/../_lib/input.fish

set width 128
set height 64

set player 1 1
set enemy $width $height
set fc 0
set frame_target (math 1000 / 12) # Target FPS

# Cache empty frame
set frame_new (graph.frame_new $width $height .)

clear
graph.hide_cursor
stty -echo
while true
    set fstart (date +%s%N)
    set key (input.nb)
    switch $key
        case h
            set player[1] (math $player[1] - 1)
        case l
            set player[1] (math $player[1] + 1)
        case j
            set player[2] (math $player[2] + 1)
        case k
            set player[2] (math $player[2] - 1)
        case q
            break
    end
    # Move enemy 
    if test $enemy[1] -lt $player[1]
        set enemy[1] (math $enemy[1] + 1)
    else if test $enemy[1] -gt $player[1]
        set enemy[1] (math $enemy[1] - 1)
    end
    if test $enemy[2] -lt $player[2]
        set enemy[2] (math $enemy[2] + 1)
    else if test $enemy[2] -gt $player[2]
        set enemy[2] (math $enemy[2] - 1)
    end
    graph.reset_cursor
    set frame $frame_new
    set frame (graph.frame_set $player[1] $player[2] c $frame)
    set frame (graph.frame_set $enemy[1] $enemy[2] r $frame)
    graph.render $frame
    # sleep 0.05
    echo "Frame: $fc"
    set fc (math $fc + 1)
    set fend (date +%s%N)
    set delta (math "($fend - $fstart) / 1000000")
    echo "Delta: $delta ms"
    echo "Target: $frame_target ms"
    set diff (math $frame_target - $delta)
    echo "Diff: $diff ms"
    if test $diff -gt 0
        sleep (math $diff / 1000)
    end
end
clear
graph.show_cursor
