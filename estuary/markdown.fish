function render_markdown
    set file $argv[1]
    if not test -f $file
        echo "File not found: $file"
        return 1
    end

    # Define ANSI codes
    set bold (set_color --bold)
    set italic (set_color --italics)
    set reset (set_color normal)
    set heading_color (set_color blue)

    cat $file | while read line
        # Headings
        if string match -r '^#{1,6} ' -- $line
            set hashes (string match -r '^#{1,6}' -- $line)
            set level (string length $hashes)
            set text (string replace -r '^#{1,6} ' '' -- $line)
            echo -n "$heading_color$bold"
            echo -n (string repeat -n $level '#')
            echo -n " $text"
            echo "$reset"
            continue
        end

        # Lists
        if string match -r '^(\-|\*) ' -- $line
            set item (string replace -r '^(\-|\*) ' '• ' -- $line)
            echo "  $item"
            continue
        end

        # Bold (**text** or __text__)
        set line (string replace -r '\*\*(.*?)\*\*' "$bold\$1$reset" -- $line)
        set line (string replace -r '__([^_]+)__' "$bold\$1$reset" -- $line)

        # Italic (*text* or _text_)
        set line (string replace -r '\*(.*?)\*' "$italic\$1$reset" -- $line)
        set line (string replace -r '_([^_]+)_' "$italic\$1$reset" -- $line)

        echo $line
    end
end

render_markdown ../README.md

# Usage: render_markdown yourfile.md
# Example: render_markdown README.md
