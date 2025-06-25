#!/usr/bin/env bash

set -euo pipefail

# Configurable position and offset
POSITION=1
YOFF=20
XOFF=30
MAX_LINES=10

# Get list of networks (SSID + signal strength)
LIST=$(nmcli -f SSID,SIGNAL,SECURITY dev wifi list | sed '/^--/d' | uniq)
KNOWN_CONNS=$(nmcli connection show | awk '{print $1}')

# Trim empty SSIDs and duplicate entries
DISPLAY_LIST=$(echo "$LIST" | awk '!seen[$1]++ && $1!=""')

# Pick network using wofi
CHENTRY=$(echo "$DISPLAY_LIST" | wofi -i -d --prompt "Select Wi-Fi:" --lines "$MAX_LINES" --location "$POSITION" --yoffset "$YOFF" --xoffset "$XOFF")

# Exit if nothing selected
[ -z "$CHENTRY" ] && exit 1

# Get selected SSID (first column)
CHSSID=$(echo "$CHENTRY" | awk '{print $1}')

# Check if this is already saved
if echo "$KNOWN_CONNS" | grep -qx "$CHSSID"; then
  nmcli connection up "$CHSSID"
else
  # Prompt for password (empty OK if open network)
  PASSWORD=$(wofi -P -d --prompt "Password for $CHSSID" --lines 1 --location "$POSITION" --yoffset "$YOFF" --xoffset "$XOFF")
  nmcli device wifi connect "$CHSSID" ${PASSWORD:+password "$PASSWORD"}
fi
