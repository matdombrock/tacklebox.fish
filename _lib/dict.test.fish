source dict.fish

set test_num 0

function section
    set_color --bold yellow
    echo -e "\n=== $argv[1] ===\n"
    set_color normal
end

function expect
    set -l actual $argv[1]
    set -l expected $argv[2]
    set test_num (math $test_num + 1)
    set_color white
    echo -n "$test_num: "
    if test "$actual" = "$expected"
        set_color green
        echo "PASS: Expected '$expected', got '$actual'"
    else
        set_color red
        echo "FAIL: Expected '$expected', got '$actual'"
        exit 1
    end
end

set dt
function reset
    set dt \
        name="Alice" \
        age="8" \
        desc="A curious girl" \
        city="Wonderland"
end

reset
section "Testing dict.get"
expect Alice (dict.get name $dt)
expect 8 (dict.get age $dt)
expect "A curious girl" (dict.get desc $dt)
expect Wonderland (dict.get city $dt)
expect null (dict.get country $dt)

reset
section "Testing dict.set"
set dt (dict.set name "Bob" $dt)
expect Bob (dict.get name $dt)
set dt (dict.set age "25" $dt)
expect 25 (dict.get age $dt)
set dt (dict.set desc "He's a builder" $dt)
expect "He's a builder" (dict.get desc $dt)
set dt (dict.set city "Builderland" $dt)
expect Builderland (dict.get city $dt)
set dt (dict.set country "Buildonia" $dt)
expect Buildonia (dict.get country $dt)
expect 5 (count $dt)

reset
section "Testing dict.remove"
set dt (dict.remove age $dt)
expect null (dict.get age $dt)
expect 3 (count $dt)
set dt (dict.remove desc $dt)
expect null (dict.get desc $dt)
expect 2 (count $dt)
set dt (dict.remove name $dt)
expect null (dict.get name $dt)
expect 1 (count $dt)
set dt (dict.remove city $dt)
expect null (dict.get city $dt)
expect 0 (count $dt)

reset
section "Testing dict.keys"
expect name (dict.keys $dt)[1]
expect age (dict.keys $dt)[2]
expect desc (dict.keys $dt)[3]
expect city (dict.keys $dt)[4]
expect 4 (count (dict.keys $dt))

reset
section "Testing dict.values"
expect Alice (dict.values $dt)[1]
expect 8 (dict.values $dt)[2]
expect "A curious girl" (dict.values $dt)[3]
expect Wonderland (dict.values $dt)[4]
expect 4 (count (dict.values $dt))

reset
section "Testing dict.expand"
set expanded (dict.expand (echo $dt))
expect Alice (dict.get name $expanded)
expect 8 (dict.get age $expanded)
expect "A curious girl" (dict.get desc $expanded)
expect Wonderland (dict.get city $expanded)
expect 4 (count $expanded)

set_color green
echo -e "\nAll tests passed."
