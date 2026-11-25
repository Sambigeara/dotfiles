function fish_prompt --description 'Write out the prompt'
    set -l last_pipestatus $pipestatus
    set -lx __fish_last_status $status # Export for __fish_print_pipestatus.

    set -l color_cwd
    set -l suffix
    if functions -q fish_is_root_user; and fish_is_root_user
        if set -q fish_color_cwd_root
            set color_cwd $fish_color_cwd_root
        else
            set color_cwd $fish_color_cwd
        end
        set suffix '#'
    else
        set color_cwd $fish_color_cwd
        set suffix '$'
    end

    # Host
    set -l host_color (set_color --bold blue)
    set -l host_seg $host_color(prompt_hostname)":"(set_color normal)
    echo -n $host_seg

    # PWD
    set_color --bold $color_cwd
    echo -n (prompt_pwd)
    set_color normal

    if set -l branch (__git_branch)
        echo -ns ' (' (set_color --bold magenta) $branch (set_color normal) ')'
    end
    echo -n ' '

    set -l status_color (set_color $fish_color_status)
    set -l statusb_color (set_color --bold $fish_color_status)
    set -l prompt_status (__fish_print_pipestatus "[" "]" "|" "$status_color" "$statusb_color" $last_pipestatus)
    echo -n $prompt_status
    set_color normal

    echo -n "$suffix "
end
