#!/usr/bin/env bash

# Read total CPU usage
read cpu user nice system idle iowait irq softirq steal guest < /proc/stat
sleep 1
read cpu2 user2 nice2 system2 idle2 iowait2 irq2 softirq2 steal2 guest2 < /proc/stat

total1=$((user + nice + system + idle + iowait + irq + softirq + steal))
total2=$((user2 + nice2 + system2 + idle2 + iowait2 + irq2 + softirq2 + steal2))
total_diff=$((total2 - total1))
idle_diff=$((idle2 - idle))

usage=$((100 * (total_diff - idle_diff) / total_diff))

if [ "$usage" -lt 30 ]; then
  class="low"
elif [ "$usage" -lt 70 ]; then
  class="medium"
else
  class="high"
fi

# Build tooltip dynamically with per-core usage:

tooltip_text=""

# Get all cores (lines starting with cpu + digit)
mapfile -t cores < <(grep '^cpu[0-9]' /proc/stat)
sleep 1
mapfile -t cores2 < <(grep '^cpu[0-9]' /proc/stat)

for i in "${!cores[@]}"; do
  read -r cpu user nice system idle iowait irq softirq steal guest < <(echo "${cores[i]}")
  read -r cpu2 user2 nice2 system2 idle2 iowait2 irq2 softirq2 steal2 guest2 < <(echo "${cores2[i]}")

  total1=$((user + nice + system + idle + iowait + irq + softirq + steal))
  total2=$((user2 + nice2 + system2 + idle2 + iowait2 + irq2 + softirq2 + steal2))
  total_diff=$((total2 - total1))
  idle_diff=$((idle2 - idle))

  core_usage=$((100 * (total_diff - idle_diff) / total_diff))

  tooltip_text+="Core $i: $core_usage%\n"
done

# Escape newlines for JSON tooltip field
tooltip_text="${tooltip_text//$'\n'/\\n}"

echo "{\"text\": \"🧮 ${usage}%\", \"tooltip\": \"$tooltip_text\", \"class\": \"$class\"}"
