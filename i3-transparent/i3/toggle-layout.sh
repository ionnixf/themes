#!/bin/sh

"$HOME/.config/i3/xkb-layout" toggle >/dev/null || exit $?

# Refresh only the language block immediately when i3blocks is active.
pkill -RTMIN+2 -x i3blocks 2>/dev/null || true
