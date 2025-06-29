#!/usr/bin/env bash

wifi_icon=""  # Unicode wifi icon

# Get actual wifi signal strength (%)
wifi_strength=$(nmcli -t -f active,ssid,signal dev wifi | awk -F: '$1 == "yes" { print $3 }')

if [[ -z "$wifi_strength" ]]; then
  # Not connected
  echo '{"text": "睊", "class": "critical"}'  # Disconnected icon and red color
  exit 0
fi

strength_value=$wifi_strength
wifi_strength="${wifi_strength}%"

# Choose class for color based on thresholds
if [ "$strength_value" -le 30 ]; then
  color_class="normal"       # cyan color in CSS
elif [ "$strength_value" -le 69 ]; then
  color_class="warning"      # yellow color in CSS
else
  color_class="critical"     # pink color in CSS
fi

# Output JSON with icon and inside % value
# You can put the % inside the text string as a 'fake' inside, since no real text rendering inside icon

echo "{\"text\": \"$wifi_icon $wifi_strength\", \"class\": \"$color_class\"}"
