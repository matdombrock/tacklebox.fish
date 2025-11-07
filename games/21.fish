#! /usr/bin/env fish

source ../lib/input.fish

function draw_card
    set cards 2 3 4 5 6 7 8 9 10 11
    echo $cards[(random 1 (count $cards))]
end

function hand_value
    set hand $argv
    set total 0
    set aces 0
    for card in $hand
        if test $card -eq 11
            set aces (math $aces + 1)
        end
        set total (math $total + $card)
    end
    while test $total -gt 21; and test $aces -gt 0
        set total (math $total - 10)
        set aces (math $aces - 1)
    end
    echo $total
end

set player (draw_card) (draw_card)
set dealer (draw_card) (draw_card)

set_color bryellow
echo "Type 'q' to quit at any time."
set_color brgreen
echo "Your cards: $player"
echo "Dealer shows: $dealer[1]"

while true
    set value (hand_value $player)
    if test $value -gt 21
        set_color brred
        echo "You bust with $value! Dealer wins."
        exit
    end
    echo "Your total: $value"
    set_color green
    set choice (input.line "$(set_color yellow)(h)it, (s)tand: ")
    if test "$choice" = q
        set_color normal
        echo "Game quit. Goodbye!"
        exit
    else if test "$choice" = h
        set player $player (draw_card)
        set_color bryellow
        echo "You drew: $player[-1]"
    else if test "$choice" = s
        break
    end
end

echo "Dealer's cards: $dealer"
while true
    set dvalue (hand_value $dealer)
    if test $dvalue -lt 17
        set dealer $dealer (draw_card)
        set_color bryellow
        echo "Dealer draws: $dealer[-1]"
    else
        break
    end
end
echo "Dealer total: $dvalue"

set pvalue (hand_value $player)
if test $dvalue -gt 21
    set_color brgreen
    echo "Dealer busts! You win."
else if test $pvalue -gt $dvalue
    set_color brgreen
    echo "You win!"
else if test $pvalue -eq $dvalue
    set_color bryellow
    echo "It's a tie!"
else
    set_color brred
    echo "Dealer wins!"
end
