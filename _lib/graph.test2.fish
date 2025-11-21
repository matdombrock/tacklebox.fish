source ./graph.fish

set frames

set -a frames "\
. . . . . . . . .
. . . . . . . . .
. . . . . . . . .
. . . . . . . . .
. . . . . . . . .
. . . . . . . . .
. . . . . . . . .
. . . . . . . . .
. . . m . . . . .
y y g m g g g . .
y y g m y y g r .
. g g m y y r r r"

set -a frames "\
. . . . . r . . .
. . . . . . . . .
. . . . . . . . .
. . . . . . . . .
. . . . . . . . .
. . . . . . . . .
. . . . . . . . .
. . . . . . . . .
. . . m . . . . .
y y g m g g g . .
y y g m y y g r .
. g g m y y r r r"

set -a frames "\
. . . . r r r . .
. . . . . r . . .
. . . . . . . . .
. . . . . . . . .
. . . . . . . . .
. . . . . . . . .
. . . . . . . . .
. . . . . . . . .
. . . m . . . . .
y y g m g g g . .
y y g m y y g r .
. g g m y y r r r"

set -a frames "\
. . . . . . . . .
. . . . r r r . .
. . . . . r . . .
. . . . . . . . .
. . . . . . . . .
. . . . . . . . .
. . . . . . . . .
. . . . . . . . .
. . . m . . . . .
y y g m g g g . .
y y g m y y g r .
. g g m y y r r r"

set -a frames "\
. . . . . . . . .
. . . . . . . . .
. . . . . r . . .
. . . . r r . . .
. . . . . r . . .
. . . . . . . . .
. . . . . . . . .
. . . . . . . . .
. . . m . . . . .
y y g m g g g . .
y y g m y y g r .
. g g m y y r r r"

set -a frames "\
. . . . . . . . .
. . . . . . . . .
. . . . . . . . .
. . . . . . r . .
. . . . . r r . .
. . . . . . r . .
. . . . . . . . .
. . . . . . . . .
. . . m . . . . .
y y g m g g g . .
y y g m y y g r .
. g g m y y r r r"

set -a frames "\
. . . . . . . . .
. . . . . . . . .
. . . . . . . . .
. . . . . . . . .
. . . . . . . r .
. . . . . . r r .
. . . . . . . r .
. . . . . . . . .
. . . m . . . . .
y y g m g g g . .
y y g m y y g r .
. g g m y y r r r"

set -a frames "\
. . . . . . . . .
. . . . . . . . .
. . . . . . . . .
. . . . . . . . .
. . . . . . . . .
. . . . . . . r .
. . . . . . r r .
. . . . . . . r .
. . . m . . . . .
y y g m g g g . .
y y g m y y g r .
. g g m y y r r r"

set -a frames "\
. . . . . . . . .
. . . . . . . . .
. . . . . . . . .
. . . . . . . . .
. . . . . . . . .
. . . . . . . . .
. . . . . . . . r
. . . . . . . r r
. . . m . . . . r
y y g m g g g . .
y y g m y y g r .
. g g m y y r r r"

set -a frames "\
. . . . . . . . .
. . . . . . . . .
. . . . . . . . .
. . . . . . . . .
. . . . . . . . .
. . . . . . . . .
. . . . . . . . .
. . . . . . . . .
. . . m . . . . r
y y g m g g g r r
y y g m y y g r r
. g g m y y r r r"

set -a frames "\
. . . . . . . . .
. . . . . . . . .
. . . . . . . . .
. . . . . . . . .
. . . . . . . . .
. . . . . . . . .
. . . . . . . . .
. . . . . . . . .
. . . m . . . . r
y y g m g g g r r
w w w w w w w w w
. g g m y y r r r"

set -a frames "\
. . . . . . . . .
. . . . . . . . .
. . . . . . . . .
. . . . . . . . .
. . . . . . . . .
. . . . . . . . .
. . . . . . . . .
. . . . . . . . .
. . . m . . . . r
y y g m g g g r r
y y g m y y g r r
. g g m y y r r r"

set -a frames "\
. . . . . . . . .
. . . . . . . . .
. . . . . . . . .
. . . . . . . . .
. . . . . . . . .
. . . . . . . . .
. . . . . . . . .
. . . . . . . . .
. . . m . . . . r
y y g m g g g r r
w w w w w w w w w
. g g m y y r r r"

set -a frames "\
. . . . . . . . .
. . . . . . . . .
. . . . . . . . .
. . . . . . . . .
. . . . . . . . .
. . . . . . . . .
. . . . . . . . .
. . . . . . . . .
. . . . . . . . .
. . . m . . . . r
y y g m g g g r r
. g g m y y r r r"

clear
# Hide cursor
echo -en "\033[?25l"
for frame in $frames
    # Reset cursor position
    echo -en "\033[H"
    graph.render $frame
    sleep (math 1 / 8)
end
# Show cursor
echo -en "\033[?25h"
