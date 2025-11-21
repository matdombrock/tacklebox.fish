#! /usr/bin/env fish

source (dirname (realpath (status --current-filename)))/../_lib/graph.fish
source (dirname (realpath (status --current-filename)))/../_lib/input.fish

set width $argv[1]
if test -z "$width"
    set width 16
end
set height $argv[2]
if test -z "$height"
    set height 16
end
set enemy_count $argv[3]
if test -z "$enemy_count"
    set enemy_count 2
end

clear

set title "\
. . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .
. r r r r . r . . b . . r r . . r r r . . b . . b . r r r r . r .
. r . . . . b . . b . r . . r . r . . b . b . . r . . . . r . b .
. r . . . . b . . r . r . . r . r . . b . b . r . . . . r . . b .
. r r r b . b b b r . r r r r . r b b . . b r . . . r r r b . b .
. . . . b . b . . r . r . . r . b . . b . r . r . . . r . . . b .
. . . . b . b . . r . r . . r . b . . b . r . . r . r . . . . . .
. b b b b . b . . r . r . . b . b . . r . r . . r . b b b b . r .
. . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .
W W W W W W W W W W W W W W W W W W W W W W W W W W W W W W W W W
. . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .
"

graph.render $title half
set_color brgreen
echo COntrols:
set_color bryellow
echo h j k l
echo ↙b ↘n ↖y ↗u

input.char "Press any key to start..."
clear

set points 0

function sharks
    # Hide cursor
    echo -en "\033[?25l"
    # Initialize enemies (x1 y1 x2 y2 ...)
    set enemies
    for i in (seq 1 $enemy_count)
        set -l ex (random 1 $width)
        set -l ey (random 1 $height)
        set -a enemies $ex $ey
    end

    set player (math round (math $width / 2)) (math round (math $height / 2))
    set boat (random 1 $width) (random 1 $height)
    while true
        set frame (graph.frame_new $width $height L | string collect)
        set frame (graph.frame_set $player[1] $player[2] g $frame | string collect)
        # Render all enemies
        for idx in (seq 1 2 (math (count $enemies) - 1))
            set x $enemies[$idx]
            set y $enemies[(math $idx + 1)]
            set frame (graph.frame_set $x $y R $frame | string collect)
        end
        set frame (graph.frame_set $boat[1] $boat[2] b $frame | string collect)
        # clear
        echo -en "\033[H" # Reset cursor position
        graph.render $frame full
        # Check for escape
        if test $player[1] -eq 0; or test $player[1] -eq (math $width + 1); or test $player[2] -eq 0; or test $player[2] -eq (math $height + 1)
            set_color green
            echo "You escaped! You survive!"
            set points (math $points + 1)
            break
        end
        # Check for reaching boat
        if test $player[1] -eq $boat[1]; and test $player[2] -eq $boat[2]
            set_color green
            echo "You reached the boat! You survive!"
            set points (math $points + 3)
            break
        end
        # Check for collision with any enemy
        set collision 0
        for idx in (seq 1 2 (math (count $enemies) - 1))
            set x $enemies[$idx]
            set y $enemies[(math $idx + 1)]
            if test $player[1] -eq $x; and test $player[2] -eq $y
                set collision 1
                break
            end
        end
        if test $collision -eq 1
            set_color red
            echo "Game Over! The sharks caught you."
            set points (math $points - 1)
            break
        end
        set inp (input.char "")
        if test "$inp" = k
            set -l new_y (math $player[2] - 1)
            set player $player[1] $new_y
        else if test "$inp" = j
            set -l new_y (math $player[2] + 1)
            set player $player[1] $new_y
        else if test "$inp" = h
            set -l new_x (math $player[1] - 1)
            set player $new_x $player[2]
        else if test "$inp" = l
            set -l new_x (math $player[1] + 1)
            set player $new_x $player[2]
        else if test "$inp" = b
            set -l new_x (math $player[1] - 1)
            set -l new_y (math $player[2] + 1)
            set player $new_x $new_y
        else if test "$inp" = n
            set -l new_x (math $player[1] + 1)
            set -l new_y (math $player[2] + 1)
            set player $new_x $new_y
        else if test "$inp" = y
            set -l new_x (math $player[1] - 1)
            set -l new_y (math $player[2] - 1)
            set player $new_x $new_y
        else if test "$inp" = u
            set -l new_x (math $player[1] + 1)
            set -l new_y (math $player[2] - 1)
            set player $new_x $new_y
        else if test "$inp" = q
            break
        end
        # Move each enemy towards player
        set new_enemies
        for idx in (seq 1 2 (math (count $enemies) - 1))
            set x $enemies[$idx]
            set y $enemies[(math $idx + 1)]
            if test $x -lt $player[1]
                set x (math $x + 1)
            else if test $x -gt $player[1]
                set x (math $x - 1)
            end
            if test $y -lt $player[2]
                set y (math $y + 1)
            else if test $y -gt $player[2]
                set y (math $y - 1)
            end
            set new_enemies $new_enemies $x $y
        end
        set enemies $new_enemies

        # Move boat towards player slowly
        if test (random 1 2) -eq 1
            set bx $boat[1]
            set by $boat[2]
            if test $bx -lt $player[1]
                set bx (math $bx + 1)
            else if test $bx -gt $player[1]
                set bx (math $bx - 1)
            end
            if test $by -lt $player[2]
                set by (math $by + 1)
            else if test $by -gt $player[2]
                set by (math $by - 1)
            end
            set boat $bx $by
        end
    end
    # Show cursor
    echo -en "\033[?25h"
    echo "Points: $points"
    set again ""
    while test $again != y; and test $again != n
        set again (input.char "$(set_color brgreen)Play Sharks again? (y/n): ")
        if test "$again" = y
            clear
            sharks
        end
    end
end

sharks
