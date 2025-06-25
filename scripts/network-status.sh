#!/usr/bin/env bash

interface="wlo1"
signal=$(nmcli -f IN-USE,SIGNAL device wifi list ifname "$interface" | grep '*' | awk '{print $2}')

if [ -n "$signal" ]; then
    echo " ${signal}%"
else
    echo "⚠ Disconnected"
fi


