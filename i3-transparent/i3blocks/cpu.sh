#!/bin/sh

prev_total=0
prev_idle=0

while :; do
    set -- $(sed -n 's/^cpu  //p' /proc/stat)
    idle=$4
    total=0

    for value in "$@"; do
        total=$((total + value))
    done

    percent=0
    if [ "$prev_total" -gt 0 ] && [ "$total" -gt "$prev_total" ]; then
        delta=$((total - prev_total))
        idle_delta=$((idle - prev_idle))
        percent=$((100 * (delta - idle_delta) / delta))
    fi

    printf '󰻠 %s%%\n' "$percent"
    prev_total=$total
    prev_idle=$idle
    sleep 2
done
