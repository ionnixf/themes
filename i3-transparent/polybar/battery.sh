#!/bin/sh

for battery in /sys/class/power_supply/BAT*; do
    [ -r "$battery/capacity" ] || continue

    capacity=$(cat "$battery/capacity")
    status=$(cat "$battery/status" 2>/dev/null)

    case $status in
        Charging|Full) icon="󰂄" ;;
        *)             icon="󰁹" ;;
    esac

    printf '%s %s%%\n' "$icon" "$capacity"
    exit 0
done

exit 0
