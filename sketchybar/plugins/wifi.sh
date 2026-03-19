#!/bin/bash

if [ "$SENDER" = "mouse.clicked" ]; then
  open "x-apple.systempreferences:com.apple.preference.network"
  return
fi

IP=$(ipconfig getifaddr en0 2>/dev/null)
if [ -z "$IP" ]; then
  sketchybar --set "$NAME" icon="󰤭" icon.color="$RED" label="Off"
else
  SSID=$(ipconfig getsummary en0 2>/dev/null | awk -F ' SSID : ' '/ SSID : / {print $2}')
  sketchybar --set "$NAME" icon="󰤨" icon.color="$TEXT" label="${SSID:-Connected}"
fi
