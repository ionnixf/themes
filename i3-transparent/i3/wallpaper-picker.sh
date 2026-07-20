#!/usr/bin/env bash

set -u

config_home=${XDG_CONFIG_HOME:-"$HOME/.config"}
wallpaper_dir=${WALLPAPER_DIR:-"$HOME/Pictures/Wallpapers"}
theme="$config_home/rofi/wallpaper-picker.rasi"
setter="$config_home/i3/set-wallpaper.sh"

notify_error() {
    command -v notify-send >/dev/null 2>&1 && notify-send "Wallpaper picker" "$1"
    printf '%s\n' "$1" >&2
}

[[ -d $wallpaper_dir ]] || {
    notify_error "Wallpaper directory not found"
    exit 1
}

command -v rofi >/dev/null 2>&1 || {
    notify_error "Rofi is not installed"
    exit 1
}

[[ -x $setter ]] || {
    notify_error "Wallpaper setter is unavailable"
    exit 1
}

mapfile -d '' -t wallpapers < <(
    find "$wallpaper_dir" -maxdepth 1 -type f \
        \( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.webp' \) \
        -print0 | LC_ALL=C sort -z
)

((${#wallpapers[@]})) || {
    notify_error "No supported images found"
    exit 1
}

if ! choice=$(
    for image in "${wallpapers[@]}"; do
        filename=${image##*/}
        label=${filename%.*}
        label=${label//$'\n'/ }
        printf '%s\0icon\x1f%s\n' "$label" "$image"
    done | rofi -dmenu -i -no-custom -show-icons -format i \
        -p "Wallpaper" -theme "$theme"
); then
    exit 0
fi

[[ $choice =~ ^[0-9]+$ ]] || exit 0
((choice < ${#wallpapers[@]})) || exit 1

exec "$setter" --file "${wallpapers[$choice]}"
