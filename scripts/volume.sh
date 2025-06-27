#!/usr/bin/env bash

VOLUME=$(pamixer --get-volume)
MUTED=$(pamixer --get-mute)

if [ "$MUTED" = "true" ]; then
  ICON="🔇"
  COLOR="#666666"
  CLASS="muted"
elif [ "$VOLUME" -lt 30 ]; then
  ICON="🔉"
  COLOR="#43fbff"
  CLASS="low"
elif [ "$VOLUME" -lt 70 ]; then
  ICON="🔉"
  COLOR="#FFD300"
  CLASS="medium"
else
  ICON="🔊"
  COLOR="#FF06B5"
  CLASS="high"
fi

echo "{\"text\": \"$ICON $VOLUME%\", \"class\": \"$CLASS\", \"color\": \"$COLOR\"}"
