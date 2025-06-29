#!/usr/bin/env bash

temp=$(cat /sys/class/thermal/thermal_zone0/temp)
temp_c=$((temp / 1000))

if [ "$temp_c" -le 50 ]; then
  color_class="normal"
elif [ "$temp_c" -le 85 ]; then
  color_class="warning"
else
  color_class="critical"
fi

echo "{\"text\": \"CPU ${temp_c}°C\", \"class\": \"$color_class\"}"
