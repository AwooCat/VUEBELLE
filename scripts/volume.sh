#!/usr/bin/env bash

volume=$(pamixer --get-volume 2>/dev/null || echo "0")
if ! [[ "$volume" =~ ^[0-9]+$ ]]; then
  volume=0
fi

color="#43fbff"  # default

if [ "$volume" -ge 70 ]; then
  color="#FF06B5"
elif [ "$volume" -ge 50 ]; then
  color="#FFD300"
fi

icon="🔊"

echo "{\"text\": \"$icon $volume%\", \"class\": \"\", \"color\": \"$color\"}"
