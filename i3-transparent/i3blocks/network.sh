#!/bin/sh

network=offline

for interface in /sys/class/net/*; do
    [ "${interface##*/}" = lo ] && continue
    [ "$(cat "$interface/operstate" 2>/dev/null)" = up ] || continue
    network=${interface##*/}
    break
done

printf '󰈀 %s\n' "$network"
