if status is-interactive
    # Commands to run in interactive sessions can go here

    # misc
    function git-prune-local
        set -l tracking (git branch -r | awk '{print $1}' | egrep -v -f /dev/fd/0 (git branch -vv | grep origin | psub) | awk '{print $1}')
        if set -q tracking[1]
            git branch -D $tracking
        end

        # No upstream and no origin/<name>. Only delete when every commit is already
        # on origin and the branch is not checked out.
        set -l tab (printf '\t')
        git for-each-ref --format='%(refname:short)%09%(upstream)%09%(worktreepath)' refs/heads | while read -l line
            set -l fields (string split -- $tab $line)
            set -l b $fields[1]
            test -z "$fields[2]"; or continue
            test -z "$fields[3]"; or continue
            git show-ref --verify --quiet "refs/remotes/origin/$b"; and continue
            test (git rev-list --count $b --not --remotes=origin) -eq 0; or continue
            git branch -D $b
        end
    end

    # cd cfg
    function cfg
        if set -q argv[1]
            cd ~/dotfiles/$argv[1]
            # nvim -c ":Oil"
            nvim
        else
            cd ~/dotfiles
        end
    end
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

set -x EDITOR nvim
# set -x EDITOR hx

# FZN
set -x FZN_EDITOR nvim

# User-installed executables (including Amp)
fish_add_path $HOME/.local/bin

# Helm
set -x HELM_SECRETS_BACKEND vals

# n (node package manager)
set -x N_PREFIX $HOME/.n
fish_add_path $HOME/.n/bin

# Point to source-built Helix runtime
if test -d ~/code/helix/runtime
    set -x HELIX_RUNTIME ~/code/helix/runtime
end
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
# direnv hook fish | source

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

# Added by OrbStack: command-line tools and integration
# This won't be added again if you remove it.
source ~/.orbstack/shell/init2.fish 2>/dev/null || :

# Keep the personal Fish prompt after Omarchy's vendor initialization.
if status is-interactive
    source $__fish_config_dir/functions/fish_prompt.fish
    functions --erase fish_right_prompt
end
