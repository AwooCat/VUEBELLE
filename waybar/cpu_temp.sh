#!/usr/bin/env bash

# Read CPU temperature from thermal_zone0 (adjust if needed)
temp_raw=$(cat /sys/class/thermal/thermal_zone0/temp 2>/dev/null)

if [[ -n "$temp_raw" ]]; then
  temp=$((temp_raw / 1000))
  echo "{\"text\": \" ${temp}°C\"}"
else
  echo "{\"text\": \" N/A\"}"
fi
