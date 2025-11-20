function _fish_prompt
    set -l userIcon ''
    set -l hostIcon ''
    set -l folderIcon ''
    set -l gitIcon ''
    set -l prompIcon λ
    set -l line1Icon '┌'
    set -l line2Icon '└'
    set_color brcyan
    echo -n "$line1Icon"
    set_color bryellow
    echo -n "$userIcon $(whoami)"
    echo -n " $hostIcon $(hostname)"
    echo -n " $folderIcon $(prompt_pwd)"
    set_color green
    echo -n "  $gitIcon$(fish_git_prompt)"
    set_color bryellow
    echo -n "▶"
    echo -e ""
    set_color brcyan
    echo -n "$line2Icon"
    set_color bryellow
    echo -n "$prompIcon "
    set_color normal
end
