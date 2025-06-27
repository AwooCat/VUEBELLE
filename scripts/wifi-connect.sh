#!/usr/bin/env bash

set -euo pipefail

iface=wlo1  # Change this to your WiFi interface name if needed

# List unique SSIDs (non-empty)
networks=$(nmcli -t -f SSID dev wifi | grep -v '^$' | sort -u)

# Use wofi GUI to select a WiFi network
network=$(echo "$networks" | wofi --dmenu --prompt="Select Wi-Fi network:")

# Exit if none selected
if [ -z "$network" ]; then
  echo "No network selected."
  exit 1
fi

# Ask for password via GUI (masked)
password=$(wofi --dmenu --password --prompt="Enter Wi-Fi password for $network:")

# Password can be empty for open networks, but you can add checks if you want

# Remove existing connection with same name to avoid conflict
nmcli connection delete "$network" 2>/dev/null || true

# Add and connect to the network
nmcli connection add type wifi ifname "$iface" con-name "$network" ssid "$network" \
  wifi-sec.key-mgmt wpa-psk wifi-sec.psk "$password"

nmcli connection up "$network"

# Notify success or failure
if [ $? -eq 0 ]; then
  notify-send "WiFi" "Connected to $network"
else
  notify-send "WiFi" "Failed to connect to $network"
fi
