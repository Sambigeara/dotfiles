#!/bin/bash

if [ "$SENDER" = "mouse.clicked" ]; then
  open "x-apple.systempreferences:com.apple.preference.network"
  return
fi

IP=$(ipconfig getifaddr en0 2>/dev/null)
if [ -z "$IP" ]; then
  sketchybar --set "$NAME" icon="󰤭" icon.color="$RED" label="Off"
else
  SSID=$(system_profiler SPAirPortDataType 2>/dev/null | awk '/Current Network Information:/{found=1; next} found && /^ +[^ ]/{gsub(/^ +| *:$/,"",$0); print; exit}')
  sketchybar --set "$NAME" icon="󰤨" icon.color="$TEXT" label="${SSID:-Connected}"
fi
