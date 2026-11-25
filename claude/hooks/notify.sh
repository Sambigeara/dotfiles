#!/bin/bash
# ~/.claude/hooks/notify.sh

SESSION=$(tmux display-message -t "$TMUX_PANE" -p '#{session_name}')
WINDOW_NAME=$(tmux display-message -t "$TMUX_PANE" -p '#{window_name}')
WINDOW=$(tmux display-message -t "$TMUX_PANE" -p '#{window_index}')
SOCKET=$(echo "$TMUX" | cut -d',' -f1)
CLIENT=$(tmux display-message -p '#{client_tty}')

# Get git repo name for extra context
REPO=""
if git rev-parse --is-inside-work-tree &>/dev/null 2>&1; then
  REPO=" ($(basename $(git rev-parse --show-toplevel)))"
fi

MESSAGE="${1:-Needs your attention}"
SUBTITLE="$SESSION:$WINDOW_NAME$REPO"
TTY=$(tmux display-message -t "$TMUX_PANE" -p '#{pane_tty}')

# Send OSC 9 notification through the actual terminal via tmux passthrough.
# This reaches Ghostty directly, bypassing the broken tmux→NotificationCenter path.
printf '\ePtmux;\e\e]9;Claude Code [%s]: %s\a\e\\' "$SUBTITLE" "$MESSAGE" > "$TTY"
