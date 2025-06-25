#!/run/current-system/sw/bin/bash

# Show list of networks
network=$(nmcli -t -f SSID,SIGNAL dev wifi | sort -t ':' -k2 -nr | awk -F: '!seen[$1]++ && $1!=""{print $1}' | wofi --dmenu --prompt "Select Wi-Fi")

# Exit if no selection
[ -z "$network" ] && exit 1

# Check if network is already saved
if nmcli connection show "$network" &>/dev/null; then
  nmcli connection up "$network"
else
  # Prompt for password
  password=$(wofi --dmenu --password --prompt "Password for $network")
  [ -z "$password" ] && exit 1
  nmcli dev wifi connect "$network" password "$password"
fi
