set width 20
set height 10
set size (math $width x $height)
set buf
function graph.new
    set buf (string repeat -n $size '.')
end
function graph.render
    set -l frame
    for y in (seq 1 $height)
        for x in (seq 1 $width)
            set pos (math (math $y - 1) x $width + (math $x - 1))
            set -a frame (string sub -s (math $pos + 1) -l 1 $buf)
        end
        set -a frame '\n'
    end
    echo -e (string join '' $frame)
end

graph.new 20 10
graph.render
