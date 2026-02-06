if status is-interactive
    # Commands to run in interactive sessions can go here

    # misc
    function git-prune-local
        git branch -r | awk '{print $1}' | egrep -v -f /dev/fd/0 (git branch -vv | grep origin | psub) | awk '{print $1}' | xargs git branch -D
    end

    # cd cfg
    function cfg
        if set -q argv[1]
            cd ~/dotfiles/$argv[1]
            # nvim -c ":Oil"
            hx
        else
            cd ~/dotfiles
        end
    end
end

# tmux
function fp
    set -lx tmux_out (tmux list-panes -s -F '#{session_name}:#I #{window_name}' | sort -u | awk '{printf ("%s %s\\n", $1, $2)}' | fzf --query="$1" --select-1 --exit-0)
    set -lx pane (echo $tmux_out | awk '{print $1;}')
    tmux switch-client -t "$pane"
end

# Open yazi with `w`. Then, when exiting, `q` moves to the new directory. `Q` returns to the original.
function y
    set tmp (mktemp -t "yazi-cwd.XXXXXX")
    yazi $argv --cwd-file="$tmp"
    if read -z cwd <"$tmp"; and [ -n "$cwd" ]; and [ "$cwd" != "$PWD" ]
        builtin cd -- "$cwd"
    end
    rm -f -- "$tmp"
end

set -x EDITOR hx

# FZN
set -x FZN_EDITOR hx

# Helm
set -x HELM_SECRETS_BACKEND vals

# n (node package manager)
set -x N_PREFIX $HOME/.n
fish_add_path $HOME/.n/bin

# Point to source-built Helix runtime
set -x HELIX_RUNTIME ~/code/helix/runtime
fish_add_path ~/.cargo/bin
# set PATH ~/.cargo/bin $PATH

# istioctl
fish_add_path $HOME/.istioctl/bin

# Use GNU make as `make` (by default, it's installed as `gmake`)
# set PATH /opt/homebrew/opt/make/libexec/gnubin $PATH

alias vim nvim
alias dc docker-compose

# TODO(saml) uncommenting this pyenv line causes horrendous slowdowns on fish startup
# # pyenv
# pyenv init - | source

# kube
alias k kubectl

# Auto envvars
direnv hook fish | source

# TODO(saml) line causes startup slowdown
# status --is-interactive; and rbenv init - fish | source

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/samuellock/google-cloud-sdk/path.fish.inc' ]
    . '/Users/samuellock/google-cloud-sdk/path.fish.inc'
end

# Haskell
# TODO(saml) causes slight slowdowns
# set -q GHCUP_INSTALL_BASE_PREFIX[1]; or set GHCUP_INSTALL_BASE_PREFIX $HOME
# set -gx PATH $HOME/.cabal/bin /Users/samuellock/.ghcup/bin $PATH # ghcup-env

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/samuellock/google-cloud-sdk/path.fish.inc' ]
    . '/Users/samuellock/google-cloud-sdk/path.fish.inc'
end

# opencode
fish_add_path /Users/samuellock/.opencode/bin
