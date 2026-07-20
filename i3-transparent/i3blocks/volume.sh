#!/bin/sh

status=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null)

case $status in
    *MUTED*)
        printf '󰝟 muted\n'
        ;;
    *Volume*)
        percent=$(printf '%s\n' "$status" | awk '{ printf "%.0f", $2 * 100 }')
        printf '󰕾 %s%%\n' "$percent"
        ;;
    *)
        printf '󰕾 --\n'
        ;;
esac
