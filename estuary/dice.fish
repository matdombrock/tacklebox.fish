#! /usr/bin/env fish

source (dirname (realpath (status --current-filename)))/../_lib/graph.fish

set -a sides "\
l w W W W W w l
w W W W W W W w
W W W W W W W W
W W W W W W W W
W W W W W W W W
W W W W W W W W
w W W W W W W w
l w W W W W w l"

set -a sides "\
l w W W W W W W W W W W W w l
w W W W W W W W W W W W W W w
w W W W W W W W W W W W W W W
w W W W W W W W W W W W W W W
w W W W W W W W W W W W W W W
w W W W W W W W W W W W W W W
w W W W W W W W W W W W W W W
w W W W W W W W W W W W W W W
w W W W W W W W W W W W W W W
w W W W W W W W W W W W W W W
w W W W W W W W W W W W W W W
w W W W W W W W W W W W W W W
w W W W W W W W W W W W W W W
w W W W W W W W W W W W W W w
l w W W W W W W W W W W W w l
r r r r r r r r r r r r r r r"

set sides

set -a sides "\
l w W W W W W W W W W W W w l
w W W W W W W W W W W W W W w
w W W W W W W W W W W W W W W
w W W W W W W W W W W W W W W
w W W W W W W W W W W W W W W
w W W W W W W W W W W W W W W
w W W W W W l l l W W W W W W
w W W W W W l l l W W W W W W
w W W W W W l l l W W W W W W
w W W W W W w w w W W W W W W
w W W W W W W W W W W W W W W
w W W W W W W W W W W W W W W
w W W W W W W W W W W W W W W
w W W W W W W W W W W W W W w
l w W W W W W W W W W W W w l
r r r r r r r r r r r r r r r"

set -a sides "\
l w W W W W W W W W W W W w l
w W W W W W W W W W W W W W w
w W W W W W W W W W W W W W W
w W W W W W W W W l l l W W W
w W W W W W W W W l l l W W W
w W W W W W W W W l l l W W W
w W W W W W W W W w w w W W W
w W W W W W W W W W W W W W W
w W W W W W W W W W W W W W W
w W W l l l W W W W W W W W W
w W W l l l W W W W W W W W W
w W W l l l W W W W W W W W W
w W W w w w W W W W W W W W W
w W W W W W W W W W W W W W w
l w W W W W W W W W W W W w l
g g g g g g g g g g g g g g g"

set -a sides "\
l w W W W W W W W W W W W w l
w W W W W W W W W W W W W W w
w W W W W W W W W W W W W W W
w W W W W W W W W W l l l W W
w W W W W W W W W W l l l W W
w W W W W W W W W W l l l W W
w W W W W W l l l W w w w W W
w W W W W W l l l W W W W W W
w W W W W W l l l W W W W W W
w W l l l W w w w W W W W W W
w W l l l W W W W W W W W W W
w W l l l W W W W W W W W W W
w W w w w W W W W W W W W W W
w W W W W W W W W W W W W W w
l w W W W W W W W W W W W w l
b b b b b b b b b b b b b b b"

set -a sides "\
l w W W W W W W W W W W W w l
w W W W W W W W W W W W W W w
w W l l l W W W W W l l l W W
w W l l l W W W W W l l l W W
w W l l l W W W W W l l l W W
w W w w w W W W W W w w w W W
w W W W W W W W W W W W W W W
w W W W W W W W W W W W W W W
w W W W W W W W W W W W W W W
w W W W W W W W W W W W W W W
w W l l l W W W W W l l l W W
w W l l l W W W W W l l l W W
w W l l l W W W W W l l l W W
w W w w w W W W W W w w w W w
l w W W W W W W W W W W W w l
y y y y y y y y y y y y y y y"

set -a sides "\
l w W W W W W W W W W W W w l
w W W W W W W W W W W W W W w
w W l l l W W W W W l l l W W
w W l l l W W W W W l l l W W
w W l l l W W W W W l l l W W
w W w w w W W W W W w w w W W
w W W W W W l l l W W W W W W
w W W W W W l l l W W W W W W
w W W W W W l l l W W W W W W
w W W W W W w w w W W W W W W
w W l l l W W W W W l l l W W
w W l l l W W W W W l l l W W
w W l l l W W W W W l l l W W
w W w w w W W W W W w w w W w
l w W W W W W W W W W W W w l
c c c c c c c c c c c c c c c"

set -a sides "\
l w W W W W W W W W W W W w l
w W W W W W W W W W W W W W w
w W l l l W W W W W l l l W W
w W l l l W W W W W l l l W W
w W l l l W W W W W l l l W W
w W w w w W W W W W w w w W W
w W l l l W W W W W l l l W W
w W l l l W W W W W l l l W W
w W l l l W W W W W l l l W W
w W w w w W W W W W w w w W W
w W l l l W W W W W l l l W W
w W l l l W W W W W l l l W W
w W l l l W W W W W l l l W W
w W w w w W W W W W w w w W w
l w W W W W W w W W W W W w l
m m m m m m m m m m m m m m m"

# clear
# Hide cursor
echo -en "\033[?25l"

echo -n "\
ROLLING:
.
.
.
.
.
.
.
.
"

set last_random 0
set random_index 0
for i in (seq 1 6)
    while test $random_index = $last_random
        set random_index (random 1 6)
    end
    set last_random $random_index
    # echo -en "\033[H"
    # move cursor up 15 lines
    echo -en "\033[8A"
    graph.render $sides[$random_index]
    sleep 0.1
end

# Show cursor
echo -en "\033[?25h"
