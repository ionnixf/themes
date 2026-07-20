#!/bin/sh

sink=@DEFAULT_AUDIO_SINK@

case ${1:-} in
    up)
        wpctl set-volume -l 1.0 "$sink" 10%+ || exit 1
        ;;
    down)
        wpctl set-volume "$sink" 10%- || exit 1
        ;;
    mute)
        wpctl set-mute "$sink" toggle || exit 1
        ;;
    *)
        printf 'Usage: %s up | down | mute\n' "$0" >&2
        exit 2
        ;;
esac

status=$(wpctl get-volume "$sink" 2>/dev/null) || exit 0

# Refresh only the volume block immediately when i3blocks is active.
pkill -RTMIN+1 -x i3blocks 2>/dev/null || true

case $status in
    *MUTED*)
        value=0
        label="Muted"
        ;;
    *)
        value=$(printf '%s\n' "$status" | awk '{ printf "%.0f", $2 * 100 }')
        label="$value%"
        ;;
esac

if command -v notify-send >/dev/null 2>&1; then
    notify-send -a "Volume" -r 991049 \
        -h "string:x-dunst-stack-tag:volume" \
        -h "int:value:$value" \
        "Volume" "$label"
fi
