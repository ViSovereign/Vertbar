#!/bin/bash

# Memory/Board Temperature Script
# Attempts to find a temperature sensor near memory/DIMM area
# Falls back to first available board sensor if no memory-specific sensor found

# Function to get temperature from a sensor file
get_temp() {
    local input_file="$1"
    if [ -f "$input_file" ]; then
        awk '{printf "%.1f\n", $1/1000}' "$input_file"
        return 0
    fi
    return 1
}

# First pass: Look for memory/DIMM-related sensors by label
for d in /sys/class/hwmon/hwmon*; do
    [ -d "$d" ] || continue
    name=$(cat "$d/name" 2>/dev/null)
    
    for lbl in "$d"/temp*_label; do
        [ -f "$lbl" ] || continue
        label_content=$(cat "$lbl" 2>/dev/null)
        
        # Check if label indicates memory/DIMM area
        if echo "$label_content" | grep -qiE "dimm|memory|systin|mb|board"; then
            base=${lbl%_label}
            input_file="${base}_input"
            if temp=$(get_temp "$input_file"); then
                echo "$temp"
                exit 0
            fi
        fi
    done
done

# Second pass: Fallback to first non-CPU board sensor
for d in /sys/class/hwmon/hwmon*; do
    [ -d "$d" ] || continue
    name=$(cat "$d/name" 2>/dev/null)
    
    # Skip CPU temperature sensors
    [ "$name" = "k10temp" ] && continue
    [ "$name" = "coretemp" ] && continue
    
    # Find first temperature input
    input_file=$(ls "$d"/temp*_input 2>/dev/null | head -1)
    if [ -n "$input_file" ] && temp=$(get_temp "$input_file"); then
        echo "$temp"
        exit 0
    fi
done

# If nothing found, return error
echo "No temperature sensor found"
exit 1