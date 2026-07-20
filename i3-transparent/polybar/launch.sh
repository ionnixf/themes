#!/bin/sh

config="$HOME/.config/polybar/config.ini"

if [ -z "${MONITOR:-}" ]; then
    MONITOR=$(polybar --list-monitors 2>/dev/null | awk '
        /\(primary\)/ { sub(/:.*/, "", $1); print $1; exit }
    ')

    if [ -z "$MONITOR" ]; then
        MONITOR=$(polybar --list-monitors 2>/dev/null | awk '
            NR == 1 { sub(/:.*/, "", $1); print $1 }
        ')
    fi

    [ -n "$MONITOR" ] && export MONITOR
fi

if [ -z "${POLYBAR_NETWORK_INTERFACE:-}" ]; then
    POLYBAR_NETWORK_INTERFACE=$(awk '
        $2 == "00000000" && $8 == "00000000" { print $1; exit }
    ' /proc/net/route)

    if [ -z "$POLYBAR_NETWORK_INTERFACE" ]; then
        for interface in /sys/class/net/*; do
            [ "${interface##*/}" = lo ] && continue
            [ "$(cat "$interface/operstate" 2>/dev/null)" = up ] || continue
            POLYBAR_NETWORK_INTERFACE=${interface##*/}
            break
        done
    fi

    POLYBAR_NETWORK_INTERFACE=${POLYBAR_NETWORK_INTERFACE:-lo}
    export POLYBAR_NETWORK_INTERFACE
fi

exec polybar --reload --config="$config" main
