source ./graph.fish

set frame "\
wwww
wwww
wrww
rgby"

set frame2 "\
w w w w
w w w w
w r w w
r g b y"

set frame3 "\
r g b y c m l w
R G B Y C M L W"

set frame4 "\
C C . W . . . . . . . . . . . C C
C . . . . . . . . . . . . . . . C
. . g g g . g . g g g . g . g . .
. . g . . . g . g . . . g . g . W
. . r r . . r . r r r . r r r . .
. . r . . . r . . . r . r . r . .
W . b . . . b . . . b . b . b . .
. . b . . . b . b b b . b . b . .
C . . . . . . . . . . . . . . . C
C C . . . . . . . . . . . W . C C"

set frame5 "\
. . . . w w w w w w w w . . . .
. . . . w w . w w w w . . . . .
. . . . w w . . . . w w . . . .
. . . . w . . . . . . w . . . .
. . . . w w . . . . . . . . . .
. . . . w w w w w w w . . . . .
. . . . w w . w w w w . . . . .
. . . . w w . . . . w . . . . .
. . . . w w . . . . . . . . . .
. . . . . w . . . . . . . . . .
. . . . . w . . . . . . . . . .
. . . . w w . . . . . . . . . .
. . . . . w . . . . . . . . . .
. . . . w . . . . . . . . . . .
. . . . w w . . . . . . . . . .
. . . . w . . . . . . . . . . ."

set frame6 "\
. . . . . . . r .
. . . . . . r r .
. . . . . . . r .
. . . . . . . . .
. . . . . . . . .
. . . . . . . . .
. . . . . . . . .
. . . . . . . . .
. . . m . . . . .
y y g m g g g . .
y y g m y y g r .
. g g m y y r r r"

graph.render $frame2
graph.render $frame3
graph.render $frame4
graph.render $frame5
graph.render $frame6

set frame (graph.frame_new 10 10 | string collect)
set frame (graph.frame_set 1 1 g $frame | string collect)
set frame (graph.frame_set 10 10 g $frame | string collect)
graph.render $frame
