#!/usr/bin/env bash

busctl tree org.bluez | grep '/dev_' | awk -F'/' '{print $NF}' | sed 's/dev_//; s/_/:/g' | sort -u | while read -r mac; do
    path=$(busctl tree org.bluez | grep "dev_${mac//:/_}" | head -n1 | awk '{print $NF}')
    name=$(busctl get-property org.bluez "$path" org.bluez.Device1 Name 2>/dev/null | awk -F'"' '{print $2}')
    if [ -z "$name" ]; then
        name=$(busctl get-property org.bluez "$path" org.bluez.Device1 Alias 2>/dev/null | awk -F'"' '{print $2}')
    fi
    conn=$(busctl get-property org.bluez "$path" org.bluez.Device1 Connected 2>/dev/null | awk '{print $2}')
    if [ -z "$name" ]; then
        name="Unknown"
    fi
    echo "$mac|$name|$conn"
done
