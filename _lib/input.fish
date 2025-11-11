function input.line
    set -l msg $argv
    read -P $msg(set_color brwhite) choice
    if test $status -ne 0
        echo "Goodbye!"
        exit
    end
    echo $choice
end

function input.char
    set -l msg $argv
    read --nchars=1 -P $msg(set_color brwhite) char
    if test $status -ne 0
        echo "Goodbye!"
        exit
    end
    echo $char
end
