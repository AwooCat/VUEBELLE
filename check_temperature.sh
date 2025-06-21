#!/usr/bin/env bash

# Read CPU temperature from thermal_zone0
temp_raw=$(cat /sys/class/thermal/thermal_zone0/temp 2>/dev/null)

if [[ -n "$temp_raw" ]]; then
  temp=$((temp_raw / 1000))
  echo " ${temp}°C"  # Only the symbol and temperature
else
  echo " N/A"  # If temperature is unavailable
fi
