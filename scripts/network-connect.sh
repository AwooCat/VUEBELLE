#!/usr/bin/env bash

iface=wlo1

# List unique SSIDs (non-empty)
networks=$(nmcli -t -f SSID dev wifi | grep -v '^$' | sort -u)

# Ask user to pick a network
network=$(echo "$networks" | wofi --dmenu --prompt="Select Wi-Fi network:")
if [ -z "$network" ]; then
  echo "No network selected."
  exit 1
fi

# Ask for password (masked)
password=$(wofi --dmenu --password --prompt="Enter Wi-Fi password for $network:")
if [ -z "$password" ]; then
  echo "No password entered."
  exit 1
fi

# Remove existing connection if it exists to avoid conflict
nmcli connection delete "$network" 2>/dev/null

# Add connection with WPA-PSK key management and password
nmcli connection add type wifi ifname "$iface" con-name "$network" ssid "$network" \
  wifi-sec.key-mgmt wpa-psk wifi-sec.psk "$password"

# Activate the connection
nmcli connection up "$network"

if [ $? -eq 0 ]; then
  echo "Connected successfully to $network"
else
  echo "Failed to connect to $network"
fi
