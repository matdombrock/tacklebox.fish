source (dirname (realpath (status --current-filename)))/../_lib/input.fish

set graph
set graph_width 64
set graph_height 16
set graph_size (math $graph_width x $graph_height)
set graph_clear_char (set_color -b brblack red)'-'(set_color normal)

function graph.init
    set -g graph_width $argv[1]
    set -g graph_height $argv[2]
    set -g graph_clear_char $argv[3]
    set -g graph_size (math $graph_width x $graph_height)
    for i in (seq 1 $graph_size)
        set graph[$i] $graph_clear_char
    end
end

function graph.px
    set -l x $argv[1]
    set -l y $argv[2]
    set -l char $argv[3]
    if test $x -ge 0 -a $x -lt $graph_width -a $y -ge 0 -a $y -lt $graph_height
        set graph[(math $y x $graph_width + $x + 1)] $char
    end
end

function graph.string
    set -l x $argv[1]
    set -l y $argv[2]
    set -l str $argv[3]
    for i in (seq 0 (math (string length $str) - 1))
        graph.px (math $x + $i) $y (string sub -s (math $i + 1) -l 1 $str)
    end
end

function graph.line
end

function graph.render
    for y in (seq 0 (math $graph_height - 1))
        for x in (seq 0 (math $graph_width - 1))
            echo -n $graph[(math $y x $graph_width + $x + 1)]
        end
        echo -n " "
        echo
    end
end

function graph.clear
    graph.init $graph_width $graph_height $graph_clear_char
    # printf "\033[H"
    # Move cursor to top-left with tput
    tput cup 0 0
    # clear
end

function graph.cursor
    if test $argv[1] = true
        printf "\033[?25h"
    else
        printf "\033[?25l"
    end
end

# Appease LSP
if test 1 = 0
    graph.init
    graph.px
    graph.string
    graph.render
    graph.clear
    graph.cursor
end
