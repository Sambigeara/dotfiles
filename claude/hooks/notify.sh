#!/bin/bash
# ~/.claude/hooks/notify.sh

MESSAGE="${1:-Needs your attention}"

CONTEXT=""
if [ -n "$TMUX" ]; then
  CONTEXT=$(tmux display-message -t "$TMUX_PANE" -p '#{session_name}:#{window_name}')
fi
if TOPLEVEL=$(git rev-parse --show-toplevel 2>/dev/null); then
  CONTEXT="$CONTEXT ($(basename "$TOPLEVEL"))"
fi
TITLE="Claude Code${CONTEXT:+ [${CONTEXT# }]}"

if command -v notify-send >/dev/null; then
  notify-send "$TITLE" "$MESSAGE"
elif [ -n "$TMUX" ]; then
  # OSC 9 via tmux passthrough reaches Ghostty directly, bypassing the broken tmux to NotificationCenter path.
  TTY=$(tmux display-message -t "$TMUX_PANE" -p '#{pane_tty}')
  printf '\ePtmux;\e\e]9;%s: %s\a\e\\' "$TITLE" "$MESSAGE" >"$TTY"
fi
