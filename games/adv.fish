#! /usr/bin/env fish

source ../lib/dict.fish

set sc_intro \
    title="Dark Forest Adventure" \
    text="\
You wake up...
The last thing you remember is walking home through the forest.\n
You wonder what happened and where all these these small pink flowers come from?" \
    options_text="Stand up" \
    options_sc="sc_start"

set sc_start \
    title="Dark Forest Clearing" \
    text="\
You find yourself in a dark forest clearing.\n
You have been here many times before.\n
But never at night.\n
The trees around you are tall and dense, blocking out most of the moonlight.
Things feel off somehow...\n
\n
There is a dark cave next to where you stand.\n
There is a small hut down the road." \
    options_text="Enter the dark cave|Enter the hut|Continue down the road" \
    options_sc="sc_cave_entrance|sc_hut|sc_road" \
    items="pink_flower"

set sc_hut \
    title="Abandoned Hut" \
    text="\
You are inside a small abandoned hut.\n
The hut looks old and dusty. \n
You look around for useful items..." \
    options_text="Leave the hut" \
    options_sc="sc_start" \
    items="lantern"

set sc_cave_entrance \
    title="Dark Cave Entrance" \
    text="\
You are at the entrace of the dark cave.\n
It pitch black inside, but you use your lantern to look around...\n
There are flowers all over the ground." \
    options_text="Leave the cave|Go Deeper" \
    options_sc="sc_start|sc_cave_fork" \
    requires="lantern" \
    requires_msg="Its too dark to see in here!"

set sc_cave_fork \
    title="Deep in the Cave (Fork)" \
    text="\
You walk deeper into the cave for some time.\n
You are deep inside the cave.\n
The cave splits to the left and the right." \
    options_text="Cave entrance|Left|Right" \
    options_sc="sc_cave_entrance|sc_cave_sword|sc_cave_battle"

set sc_cave_sword \
    title="Tomb of the Lost Knight" \
    text="\
You find a broken sword lying on the ground." \
    options_text="Leave tomb" \
    options_sc="sc_cave_fork" \
    items="broken_sword"

set sc_cave_battle \
    title="Battle Room" \
    text="\
A battle obviously took place here!\n
There are bones scattered all over the ground.\n
There is a hallway leading back to the cave fork.\n
There is a hallway leading to a treasure room..." \
    options_text="Cave fork|Hallway" \
    options_sc="sc_cave_fork|sc_treasure_room" \
    items="treasure_room_key"

set sc_treasure_room \
    title="Treasure Room" \
    text="\
You are in a small room filled with treasure!\n
There is hallway to the battle room.\n
There is a door leading outside.\n
You see gold coins, jewels, and a large chest in the center of the room." \
    options_text="Battle room|Door to the outside" \
    options_sc="sc_cave_battle|sc_road" \
    requires="treasure_room_key" \
    requires_msg="The door is locked. You need a key to open it."

set sc_road \
    title="Dark Road" \
    text="\
You find yourself on a dark road leading out of the forest.\n
In one direction is the forest clearing where you started.\n
There is a door on the side of a cave wall.\n
You see a faint light off in the distance of the other direction." \
    options_text="Clearing|Door|Towards the light" \
    options_sc="sc_start|sc_treasure_room|sc_road_girl"

set sc_road_girl \
    title="Girl on the Road" \
    text="\
You follow the road for a while and see a small girl in a red hood\n
She is lying on the ground, crying by the side of the road.\n
As you move to pass her, she starts to stand...\n
She sprints towards you and looks up at you with big sad eyes. \n
She takes the flower from your hand and consumes it without a word. \n
She then dissappears before your eyes'." \
    options_text="Start of road|Towards the light" \
    options_sc="sc_road|sc_road_no_girl" \
    requires="pink_flower" \
    requires_alt="sc_road_no_girl" \
    takes="pink_flower"

set sc_road_no_girl \
    title="The Girl Was Here..." \
    text="\
You walk further down the road, but there is no sign of the girl who took your flower.\n
You feel a confused, but continue on your way." \
    options_text="Start of road|Towards the light" \
    options_sc="sc_road|sc_bridge"

set sc_bridge \
    title="Bridge Over the River" \
    text="\
You arrive at a bridge over a wide river.\n
On the other side of the bridge, you see a your small village with lights glowing warmly in the night. \n
The bridge looks old but sturdy enough to cross. \n
However, there is a large cloaked figure standing in the middle of the bridge, blocking your way." \
    options_text="Go back up the road|Talk to the figure" \
    options_sc="sc_road_no_girl|sc_figure"

set sc_figure \
    title="Mysterious Figure" \
    text="\
As you approach the figure, it slowly turns to face you.\n
You see that it is an old man with a long white beard and piercing blue eyes.\n
He looks at you with a mixture of sadness and wisdom.\n
" \
    options_text="Go back|Cross the bridge" \
    options_sc="sc_bridge|sc_village" \
    requires="broken_sword" \
    requires_msg="\
The figure blocks your way. \n
He tells you that only the fallen may pass.\n
You need: \n
  - Broken Sword \n
  - Shield of the Faithful \n
  - Curriass of the Damned \n
"

set sc_village \
    title="Home at Last" \
    text="\
You cross the bridge and enter your village.\n
The villagers welcome you back with open arms.\n
You feel a sense of peace and belonging that you haven't felt in a long time.\n
You have finally found your way home." \
    options_text="Quit" \
    options_sc="sc_quit"

set inventory \
    lantern="no" \
    pink_flower="no" \
    broken_sword="no" \
    treasure_room_key="no"

set last_scene sc_intro

function scene
    set -l sc $argv[1..-1]
    function pretty_item
        set -l item $argv[1]
        echo $item | string replace --all _ ' '
    end
    function new_scene
        # Indirectly get the value of the variable named in $next_scene
        set -l next_scene_data (eval echo \$$argv[1])
        scene (dict.expand $next_scene_data)
    end
    clear
    # Print title
    set_color --bold bryellow
    echo -n ===
    set_color --bold brblue
    echo -n (dict.get title $sc)
    set_color --bold bryellow
    echo -n ===\n
    # Check for requirements
    if test (dict.get requires $sc) != null
        set -l reqs_split (string split '|' (dict.get requires $sc))
        for req in $reqs_split
            if test (dict.get $req $inventory) = no
                # Check for requires_alt
                if test (dict.get requires_alt $sc) != null
                    set -l alt_scene (dict.get requires_alt $sc)
                    set last_scene $sc
                    new_scene $alt_scene
                end
                set_color bryellow
                echo -e (dict.get requires_msg $sc)\n
                echo "!!META: You need a $(pretty_item $req) to proceed."
                read --nchars=1 -P "$(set_color red)Any key to go back..."
                scene $last_scene
            else
                set_color --bold green
                echo "!!META: You have the $(pretty_item $req) required to proceed."
            end
        end
    end
    # Print text
    set_color brwhite
    echo -e (dict.get text $sc) | string trim
    # Check for takes
    if test (dict.get takes $sc) != null
        set -l takes_split (string split '|' (dict.get takes $sc))
        for take in $takes_split
            set_color --bold red
            echo "You lost your $(pretty_item $take)."
            set inventory (dict.set $take "no" $inventory)
        end
    end
    # Look for items
    if test (dict.get items $sc) != null
        set -l items_split (string split '|' (dict.get items $sc))
        for item in $items_split
            if test (dict.get $item $inventory) = no
                set_color magenta
                echo -n === You found:" "
                set_color yellow
                echo -n (pretty_item $item)\n
                set inventory (dict.set $item "yes" $inventory)
            end
        end
    end
    # Show inventory
    set_color yellow
    echo Inventory:
    for item in (dict.keys $inventory)
        if test (dict.get $item $inventory) != no
            echo -n " -$(pretty_item $item)"
        end
    end
    echo ""
    # Print options
    set -l opts (string split '|' (dict.get options_sc $sc))
    set -l opts_text (string split '|' (dict.get options_text $sc))
    set_color cyan
    for i in (seq (count $opts))
        echo "$i. $opts_text[$i]"
    end
    # Get input
    read --nchars=1 -P "$(set_color bryellow)Choose an option: " choice
    # Check if we should quit
    if test "$choice" = q
        echo "Thanks for playing!"
        exit 0
    end
    # Check if we have a number
    if not string match -qr '^[0-9]+$' $choice
        set choice 99 # Invalid choice
    end
    # Check if we have a valid choice
    if test $choice -ge 1 -a $choice -le (count $opts)
        set -l next_scene $opts[$choice]
        set last_scene $sc
        new_scene $next_scene
    else
        set_color red
        echo "Invalid choice. Try again."
        read --nchars=1 -P "$(set_color red)Any key to continue..."
        scene $sc
    end
end

scene $sc_intro
