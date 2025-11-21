source ./graph.fish

set pos 0 0

graph.init 48 20 (set_color -b brblack)" "(set_color normal)
# Hide cursor
graph.cursor false
clear
set frame 0
while true
    set in (input.nb)
    if test "$in" = q
        break
    else if test "$in" = w
        set pos[2] (math $pos[2] - 1)
    else if test "$in" = s
        set pos[2] (math $pos[2] + 1)
    else if test "$in" = a
        set pos[1] (math $pos[1] - 1)
    else if test "$in" = d
        set pos[1] (math $pos[1] + 1)
    end
    set frame (math $frame + 1)
    graph.clear
    # Draw a sine wave
    for x in (seq 0 (math $graph_width - 1))
        # Calculate phase for animation
        set phase (math $frame / 5.0)
        # Calculate sine value (range: -1 to 1)
        set rad (math "$x / $graph_width * 2 * $PI + $phase")
        set sin_val (math "sin($rad)")
        # Scale to graph height (invert y so 0 is top)
        set y (math "round(($sin_val + 1) / 2 * ($graph_height - 1))")
        graph.px $x $y (set_color -b red black)'~'(set_color normal)
    end
    graph.string 0 0 "$frame $pos[1],$pos[2]"
    graph.px $pos[1] $pos[2] (set_color -b green)@(set_color normal)
    graph.line 2 2 10 10 x
    graph.render
    # sleep (math 1 / 160.0)
end
#  Show cursor
graph.cursor true
