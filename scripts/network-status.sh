#!/usr/bin/env bash

# Example script to output wifi status with an icon and strength %

# This is a placeholder, adjust to your actual wifi status command
# For testing, this just outputs a sample JSON with icon and text

# You can parse actual wifi signal here, for now hardcoding example:
wifi_icon=""  # Unicode wifi icon
wifi_strength="54%"  # Example

# You can add classes for coloring based on strength if you want
# For example:
strength_value=54

color_class="normal"
if [ "$strength_value" -lt 30 ]; then
  color_class="critical"
elif [ "$strength_value" -lt 60 ]; then
  color_class="warning"
fi

echo "{\"text\": \"$wifi_icon $wifi_strength\", \"class\": \"$color_class\"}"
