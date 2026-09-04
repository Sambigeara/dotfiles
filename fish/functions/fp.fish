function fp
    command -q fzf; or begin
        echo "fp: fzf is not installed" >&2
        return 1
    end

    set -l fzf_opts
    if set -q argv[1]
        set fzf_opts --query="$argv" --select-1 --exit-0
    end

    tmux list-windows -a -F '#{session_name}:#I #{window_name}' \
        | command fzf $fzf_opts \
        | read -l line
    or return

    tmux switch-client -t (string split -f 1 ' ' -- $line)
end
