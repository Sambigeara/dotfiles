#!/bin/sh
# Claude Code status line - mirrors fish_prompt style
input=$(cat)

cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // empty')
model=$(echo "$input" | jq -r '.model.display_name // empty')
used=$(echo "$input" | jq -r '.context_window.used_percentage // empty')

# Shorten the path like fish's prompt_pwd (show last 2 components, ~ for home)
if [ -n "$cwd" ]; then
    short_cwd=$(echo "$cwd" | sed "s|^$HOME|~|")
    # Keep only last 2 path components if more than 2 deep
    components=$(echo "$short_cwd" | tr '/' '\n' | grep -c .)
    if [ "$components" -gt 2 ]; then
        short_cwd="…/$(echo "$short_cwd" | rev | cut -d'/' -f1-2 | rev)"
    fi
else
    short_cwd=$(pwd | sed "s|^$HOME|~|")
fi

# Git branch (skip optional locks)
git_branch=""
if git -C "$cwd" rev-parse --git-dir >/dev/null 2>&1; then
    branch=$(git -C "$cwd" -c gc.auto=0 symbolic-ref --short HEAD 2>/dev/null || git -C "$cwd" -c gc.auto=0 rev-parse --short HEAD 2>/dev/null)
    if [ -n "$branch" ]; then
        git_branch=" ($branch)"
    fi
fi

# Context usage
ctx_str=""
if [ -n "$used" ] && [ "$used" != "null" ]; then
    ctx_str=" ctx:${used}%"
fi

# Model short name
model_str=""
if [ -n "$model" ] && [ "$model" != "null" ]; then
    model_str=" [$model]"
fi

# Assemble: blue bold "mac:" + cwd + git + ctx + model
printf '\033[1;34mmac:\033[0m\033[1m%s\033[0m\033[0;35m%s\033[0m\033[0;36m%s\033[0m%s' \
    "$short_cwd" \
    "$git_branch" \
    "$ctx_str" \
    "$model_str"
