#!/bin/bash

if [ "$SENDER" = "mouse.clicked" ]; then
  open "https://github.com/notifications"
  return
fi

COUNT=$(gh api notifications 2>/dev/null | jq 'length' 2>/dev/null)

if [ -z "$COUNT" ] || [ "$COUNT" = "null" ]; then
  sketchybar --set "$NAME" icon="󰂚" icon.color="$RED" label="!"
elif [ "$COUNT" -gt 0 ]; then
  sketchybar --set "$NAME" icon="󱅫" icon.color="$PEACH" label="$COUNT" label.color="$PEACH"
else
  sketchybar --set "$NAME" icon="󰂚" icon.color="$OVERLAY0" label="0" label.color="$OVERLAY0"
fi
