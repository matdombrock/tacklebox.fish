#! /usr/bin/env fish

# Example frame
# set frame "\
# w w w w
# w w w w
# w r w w
# r g b y"

# Render frame with unicode half blocks
function graph.render
    set -l frame_str $argv[1]
    set -l mode $argv[2]
    if test -z "$mode"
        set mode half
    end
    function get_color
        set -l c $argv[1]
        switch $c
            case r
                echo red
            case g
                echo green
            case b
                echo blue
            case y
                echo yellow
            case c
                echo cyan
            case m
                echo magenta
            case w
                echo white
            case l
                echo black
            case .
                echo black
            case n
                echo normal
            case R
                echo brred
            case G
                echo brgreen
            case B
                echo brblue
            case Y
                echo bryellow
            case C
                echo brcyan
            case M
                echo brmagenta
            case W
                echo brwhite
            case L
                echo brblack
        end
    end

    set -l lines (string split \n $frame_str)
    set -l height (count $lines)
    set -l width (string length $lines[1])

    if test "$mode" = full
        # Full block rendering: each cell is two '█'
        for i in (seq 1 $height)
            set -l row (string split '' $lines[$i])
            for j in (seq 1 $width)
                set -l fg $row[$j]
                if test "$fg" = ' '
                    continue
                end
                set_color (get_color $fg)
                echo -n '██'
                set_color normal
            end
            echo ''
        end
    else
        # If odd number of lines, pad with white line
        if test (math "$height % 2") -eq 1
            set lines $lines white_line
        end

        for i in (seq 1 2 $height)
            set -l top (string split '' $lines[$i])
            set -l bottom (string split '' $lines[(math "$i + 1")])
            for j in (seq 1 $width)
                set -l fg $top[$j]
                set -l bg $bottom[$j]

                if test "$fg" = ' '; or test "$bg" = ' '
                    continue
                end

                set_color (get_color $fg)
                set_color -b (get_color $bg)

                echo -n '▀'
                set_color normal
            end
            echo ''
        end
    end
end

function graph.frame_new
    set -l w $argv[1]
    set -l h $argv[2]
    set -l c $argv[3]
    set -l frame
    for y in (seq 1 $h)
        for x in (seq 1 $w)
            set -a frame $c
        end
        set -a frame "\n"
    end
    echo -e (string join '' $frame) | string collect
end

# NOTE:
# This approach works but can result in bad indicies
# Its also not significantly faster
# set -l chars $chars[1..(math "$x - 1")] $c $chars[(math "$x + 1")..-1]
# set -a new_frame (string join '' $chars)
#
# NOTE: Not signficantly faster
# function graph.frame_set
#     set -l x $argv[1]
#     set -l y $argv[2]
#     set -l c $argv[3]
#     set -l frame $argv[4]
#     set -l lines (string split \n $frame)
#     for i in (seq 1 (count $lines))
#         if test $i = $y
#             set -l line $lines[$i]
#             # replace character at position x with c using string replace
#             set -l prefix (string sub -s 1 -l (math "$x - 1") $line)
#             set -l suffix (string sub -s (math "$x + 1") $line)
#             set -l new_line "$prefix$c$suffix"
#             set -a new_frame $new_line"\n"
#         else
#             set -a new_frame $lines[$i]"\n"
#         end
#     end
#     echo -e (string join '' $new_frame) | string collect
# end
#
# TODO:
# Batch draw calls to improve performance
# set a "pixel" in the frame at (x, y) with color c
function graph.frame_set
    set -l x $argv[1]
    set -l y $argv[2]
    set -l c $argv[3]
    set -l frame $argv[4]
    set -l new_frame
    set -l lines (string split \n $frame)
    for i in (seq 1 (count $lines))
        if test $i = $y
            set -l line $lines[$i]
            set -l chars (string split '' $line)
            for j in (seq 1 (count $chars))
                if test $j = $x
                    set -a new_frame $c
                else
                    set -a new_frame $chars[$j]
                end
            end
            set -a new_frame "\n"
        else
            set -a new_frame $lines[$i]"\n"
        end
    end
    echo -e (string join '' $new_frame) | string collect
end

# Set bulk pixels in the frame
function graph.frame_set_bulk
    set -l frame $argv[1]
    set -l points $argv[2..-1]

    set -l lines (string split \n $frame)

    for point in $points
        # Split the point string into x, y, c
        set -l parts (string split ' ' $point)
        set -l x $parts[1]
        set -l y $parts[2]
        if test $y -gt (count $lines)
            continue
        end
        if test $y -lt 1
            continue
        end
        if test $x -gt (string length $lines[$y])
            continue
        end
        if test $x -lt 1; or test $y -lt 1
            continue
        end
        set -l c $parts[3]

        # Get the line and split into characters
        set -l line $lines[$y]
        set -l chars (string split '' $line)

        # Replace character at position x (Fish arrays are 1-based)
        set chars[$x] $c

        # Reconstruct the line
        set lines[$y] (string join '' $chars)
    end

    # Output the new frame
    printf '%s\n' $lines | string collect
end
# Example usage:
# set frame (graph.frame_new 10 5 .)
# set frame (graph.frame_set_bulk $frame "1 1 r" "2 2 g" "3 3 b")
# graph.render $frame

# Reset cursor position
function graph.reset_cursor
    echo -en "\033[H"
end

# Hide the cursor
function graph.hide_cursor
    echo -en "\033[?25l"
end

# Show the cursor
function graph.show_cursor
    echo -en "\033[?25h"
end
