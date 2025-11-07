#! /usr/bin/env fish

source ../lib/input.fish

set secret (math (random)%100 + 1)
set attempts 0

echo "Guess the number (between 1 and 100):"

while true
    set guess (input.line "$(set_color green)guess> ")
    set attempts (math $attempts + 1)
    if test "$guess" -eq "$secret"
        set_color brgreen
        echo "Congratulations! You guessed it in $attempts attempts."
        break
    else if test "$guess" -lt "$secret"
        set_color brblue
        echo "Too low! Try again:"
    else if test "$guess" -gt "$secret"
        set_color bryellow
        echo "Too high! Try again:"
    else
        echo "Please enter a valid number."
    end
end
