#!/bin/bash

CPU=$(top -l 1 -n 0 | grep "CPU usage" | awk '{print int($3 + $5)}')

if [ "$CPU" -gt 80 ]; then
  COLOR="$RED"
elif [ "$CPU" -gt 60 ]; then
  COLOR="$PEACH"
elif [ "$CPU" -gt 30 ]; then
  COLOR="$YELLOW"
else
  COLOR="$BLUE"
fi

sketchybar --set "$NAME" label="${CPU}%" icon.color="$COLOR"

if [ "$SENDER" = "mouse.clicked" ]; then
  open -a "Activity Monitor"
fi
