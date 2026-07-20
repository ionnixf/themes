#!/bin/sh

awk '
    /MemTotal:/     { total = $2 }
    /MemAvailable:/ { available = $2 }
    END { printf "󰍛 %.0fG\n", (total - available) / 1024 / 1024 }
' /proc/meminfo
