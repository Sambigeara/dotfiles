if status is-interactive
    # Commands to run in interactive sessions can go here
end

set -gx PATH /opt/homebrew/bin $PATH

# Brew `node` installation due to spitfire/ui issues: https://github.com/airbnb/lottie-web/issues/2739
set PATH /opt/homebrew/opt/node@20/bin $PATH

set -x EDITOR nvim

# Go
set -x GOPATH $HOME/go
set PATH $GOPATH/bin $PATH
#set PATH $HOME/.rbenv/shims $PATH

# nix-env bin path
set PATH ~/.nix-profile/bin $PATH

# Postgres
set PATH $PATH /Applications/Postgres.app/Contents/Versions/latest/bin

# Doom Emacs
set PATH $PATH ~/.config/emacs/bin

# FZN
set -x FZN_EDITOR nvim

# Helm
set -x HELM_SECRETS_BACKEND vals

# Rust
set PATH $HOME/.cargo/bin $PATH

# Use GNU make as `make` (by default, it's installed as `gmake`)
set PATH /opt/homebrew/opt/make/libexec/gnubin $PATH

alias vim nvim
alias dc docker-compose

# TODO(saml) uncommenting this pyenv line causes horrendous slowdowns on fish startup
# # pyenv
# pyenv init - | source

# tmux

function fp
    set -lx tmux_out (tmux list-panes -s -F '#{session_name}:#I #{window_name}' | sort -u | awk '{printf ("%s %s\\n", $1, $2)}' | fzf --query="$1" --select-1 --exit-0)
    set -lx pane (echo $tmux_out | awk '{print $1;}')
    tmux switch-client -t "$pane"
end

# misc

function git-prune-local
    git branch -r | awk '{print $1}' | egrep -v -f /dev/fd/0 (git branch -vv | grep origin | psub) | awk '{print $1}' | xargs git branch -D
end

# cd cfg
function cfg
    if set -q argv[1]
        cd ~/dotfiles/$argv[1]
        nvim -c ":NvimTreeToggle"
    else
        cd ~/dotfiles
    end
end

# kube

alias k kubectl

# tailscale

alias tailscale /Applications/Tailscale.app/Contents/MacOS/Tailscale

# neorg
#alias n "vim ~/notes/index.norg"
#alias cdn "cd ~/notes && vim index.norg"

# Vim mode
set -g fish_key_bindings fish_vi_key_bindings

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
