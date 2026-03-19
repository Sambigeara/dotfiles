#!/bin/bash

# Extract the workspace number from our item name (space.1, space.2, etc.)
SID="${NAME##*.}"

if [ "$SENDER" = "aerospace_workspace_change" ]; then
  # Highlight if this is the focused workspace
  if [ "$SID" = "$AEROSPACE_FOCUSED_WORKSPACE" ]; then
    sketchybar --set "$NAME" \
      icon.highlight=on \
      label.highlight=on \
      background.border_color="$MAUVE"
  else
    sketchybar --set "$NAME" \
      icon.highlight=off \
      label.highlight=off \
      background.border_color="$TRANSPARENT"
  fi
fi

# Build app icon string for this workspace
APPS=$(aerospace list-windows --workspace "$SID" --format '%{app-name}' 2>/dev/null)
ICON_LINE=""
if [ -z "$APPS" ]; then
  ICON_LINE=" —"
else
  while IFS= read -r APP; do
    case "$APP" in
      "Alacritty")          ICON_LINE+=":alacritty:" ;;
      "Arc")                ICON_LINE+=":arc:" ;;
      "Calendar")           ICON_LINE+=":calendar:" ;;
      "ChatGPT")            ICON_LINE+=":chat_gpt:" ;;
      "Claude")             ICON_LINE+=":claude:" ;;
      "Code")               ICON_LINE+=":code:" ;;
      "Discord")            ICON_LINE+=":discord:" ;;
      "Figma")              ICON_LINE+=":figma:" ;;
      "Finder")             ICON_LINE+=":finder:" ;;
      "Firefox")            ICON_LINE+=":firefox:" ;;
      "Ghostty")            ICON_LINE+=":ghostty:" ;;
      "Google Chrome")      ICON_LINE+=":google_chrome:" ;;
      "iTerm2")             ICON_LINE+=":iterm:" ;;
      "Kitty")              ICON_LINE+=":kitty:" ;;
      "Linear")             ICON_LINE+=":linear:" ;;
      "Mail")               ICON_LINE+=":mail:" ;;
      "Messages")           ICON_LINE+=":messages:" ;;
      "Music")              ICON_LINE+=":music:" ;;
      "Notes")              ICON_LINE+=":notes:" ;;
      "Notion")             ICON_LINE+=":notion:" ;;
      "OBS")                ICON_LINE+=":obs:" ;;
      "Preview")            ICON_LINE+=":preview:" ;;
      "Safari")             ICON_LINE+=":safari:" ;;
      "Slack")              ICON_LINE+=":slack:" ;;
      "Spotify")            ICON_LINE+=":spotify:" ;;
      "Terminal")           ICON_LINE+=":terminal:" ;;
      "Visual Studio Code") ICON_LINE+=":code:" ;;
      "WhatsApp")           ICON_LINE+=":whats_app:" ;;
      "Xcode")              ICON_LINE+=":xcode:" ;;
      "Zed")                ICON_LINE+=":zed:" ;;
      "zoom.us")            ICON_LINE+=":zoom:" ;;
      *)                    ICON_LINE+=":default:" ;;
    esac
  done <<< "$APPS"
fi

sketchybar --set "$NAME" label="$ICON_LINE"
