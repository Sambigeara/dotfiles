#!/bin/bash

if [ "$SENDER" = "mouse.clicked" ]; then
  MIC_VOLUME=$(osascript -e "input volume of (get volume settings)")
  if [ "$MIC_VOLUME" -eq 0 ]; then
    osascript -e "set volume input volume 50"
  else
    osascript -e "set volume input volume 0"
  fi
fi

MIC_VOLUME=$(osascript -e "input volume of (get volume settings)")
if [ "$MIC_VOLUME" -eq 0 ]; then
  sketchybar --set "$NAME" icon="󰍭" icon.color="$RED"
else
  sketchybar --set "$NAME" icon="󰍬" icon.color="$TEXT"
fi
