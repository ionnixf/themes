#!/bin/sh

helper="$HOME/.config/i3/xkb-layout"

if [ -x "$helper" ]; then
    language=$($helper get 2>/dev/null) || language=--
else
    language=--
fi

printf '󰌌 %s\n' "$language"
