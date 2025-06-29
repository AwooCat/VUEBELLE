#!/usr/bin/env bash

# Get memory info
mem_total=$(grep MemTotal /proc/meminfo | awk '{print $2}')
mem_available=$(grep MemAvailable /proc/meminfo | awk '{print $2}')
mem_used=$((mem_total - mem_available))

# Convert to GB
used_gb=$(awk "BEGIN {printf \"%.1f\", $mem_used/1024/1024}")
total_gb=$(awk "BEGIN {printf \"%.1f\", $mem_total/1024/1024}")
percent_used=$((100 * mem_used / mem_total))

# Class for color
if [ "$percent_used" -lt 40 ]; then
  class="low"
elif [ "$percent_used" -lt 75 ]; then
  class="medium"
else
  class="high"
fi

# Top memory processes (escaped for JSON)
tooltip=$(ps --sort=-%mem -eo pid,comm,%mem --no-headers | head -n 5 | sed 's/"/\\"/g' | awk '{printf "%s\\n", $0}')

# Output JSON safely
echo "{\"text\": \"󰍛 ${used_gb}G / ${total_gb}G\", \"tooltip\": \"${tooltip}\", \"class\": \"${class}\"}"
