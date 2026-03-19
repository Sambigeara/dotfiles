#!/bin/bash

if [ "$SENDER" = "volume_change" ]; then
  VOLUME="$INFO"
elif [ "$SENDER" = "mouse.scrolled" ]; then
  DELTA=$((SCROLL_DELTA * 5))
  CURRENT=$(osascript -e "output volume of (get volume settings)")
  NEW=$((CURRENT + DELTA))
  [ "$NEW" -gt 100 ] && NEW=100
  [ "$NEW" -lt 0 ] && NEW=0
  osascript -e "set volume output volume $NEW"
  VOLUME="$NEW"
else
  VOLUME=$(osascript -e "output volume of (get volume settings)")
fi

if [ "$VOLUME" -gt 60 ]; then
  ICON="󰕾"
elif [ "$VOLUME" -gt 30 ]; then
  ICON="󰖀"
elif [ "$VOLUME" -gt 10 ]; then
  ICON="󰕿"
elif [ "$VOLUME" -gt 0 ]; then
  ICON="󰖀"
else
  ICON="󰝟"
fi

sketchybar --set "$NAME" icon="$ICON" label="${VOLUME}%"
