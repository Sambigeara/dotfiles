#!/bin/bash

BATT_INFO=$(pmset -g batt)
PERCENTAGE=$(echo "$BATT_INFO" | grep -oE '[0-9]+%' | head -1 | tr -d '%')
CHARGING=$(echo "$BATT_INFO" | grep -c "AC Power")

if [ "$CHARGING" -gt 0 ]; then
  ICON="󰂄"; COLOR="$GREEN"
elif [ "$PERCENTAGE" -gt 80 ]; then
  ICON="󰁹"; COLOR="$GREEN"
elif [ "$PERCENTAGE" -gt 60 ]; then
  ICON="󰂀"; COLOR="$GREEN"
elif [ "$PERCENTAGE" -gt 40 ]; then
  ICON="󰁾"; COLOR="$YELLOW"
elif [ "$PERCENTAGE" -gt 20 ]; then
  ICON="󰁻"; COLOR="$PEACH"
else
  ICON="󰂎"; COLOR="$RED"
fi

sketchybar --set "$NAME" icon="$ICON" icon.color="$COLOR" label="${PERCENTAGE}%"
