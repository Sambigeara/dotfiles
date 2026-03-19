#!/bin/bash

if [ "$SENDER" = "media_change" ]; then
  STATE=$(echo "$INFO" | jq -r '.state')
  if [ "$STATE" = "playing" ]; then
    ARTIST=$(echo "$INFO" | jq -r '.artist')
    TITLE=$(echo "$INFO" | jq -r '.title')
    sketchybar --set "$NAME" drawing=on label="${ARTIST} — ${TITLE}"
  else
    sketchybar --set "$NAME" drawing=off
  fi
fi

if [ "$SENDER" = "mouse.clicked" ]; then
  nowplaying-cli togglePlayPause
fi
