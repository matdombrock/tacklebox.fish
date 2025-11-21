#! /usr/bin/env fish

# Example frame
# set frame "\
# w w w w
# w w w w
# w r w w
# r g b y"

# Render frame with unicode half blocks
function graph.render
    function get_color
        switch $argv[1]
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
    set -l frame_str $argv[1]
    set -l lines (string split \n $frame_str)
    set -l height (count $lines)
    set -l width (string length $lines[1])

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
    echo -e (string join '' $frame)
end

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
            # NOTE:
            # This approach works but can result in bad indicies
            # Its also not significantly faster
            # set -l chars $chars[1..(math "$x - 1")] $c $chars[(math "$x + 1")..-1]
            # set -a new_frame (string join '' $chars)
            for j in (seq 1 (count $chars))
                if test $j = $x
                    set -a new_frame $c
                else
                    set -a new_frame $chars[$j]
                end
            end
        else
            set -a new_frame $lines[$i]
        end
        set -a new_frame "\n"
    end
    echo -e (string join '' $new_frame)
end
