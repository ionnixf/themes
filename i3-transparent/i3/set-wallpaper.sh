#!/bin/sh

config_home=${XDG_CONFIG_HOME:-"$HOME/.config"}
state_file="$config_home/i3/wallpaper"
wallpaper_dir=${WALLPAPER_DIR:-"$HOME/Pictures/Wallpapers"}

notify_error() {
    command -v notify-send >/dev/null 2>&1 && notify-send "Wallpaper" "$1"
    printf '%s\n' "$1" >&2
}

first_wallpaper() {
    [ -d "$wallpaper_dir" ] || return 1

    for candidate in "$wallpaper_dir"/*; do
        [ -r "$candidate" ] || continue
        case $candidate in
            *.png|*.PNG|*.jpg|*.JPG|*.jpeg|*.JPEG|*.webp|*.WEBP)
                printf '%s\n' "$candidate"
                return 0
                ;;
        esac
    done

    return 1
}

case ${1:-} in
    --restore)
        wallpaper=
        if [ -r "$state_file" ]; then
            IFS= read -r saved < "$state_file" || saved=
            [ -r "$saved" ] && wallpaper=$saved
        fi
        if [ -z "$wallpaper" ]; then
            wallpaper=$(first_wallpaper) || {
                notify_error "No wallpaper is available in $wallpaper_dir"
                exit 1
            }
        fi
        ;;
    --file)
        [ "$#" -eq 2 ] || {
            printf 'Usage: %s --restore | --file IMAGE\n' "$0" >&2
            exit 2
        }
        wallpaper=$2
        ;;
    *)
        printf 'Usage: %s --restore | --file IMAGE\n' "$0" >&2
        exit 2
        ;;
esac

[ -r "$wallpaper" ] || {
    notify_error "Wallpaper is unavailable: $wallpaper"
    exit 1
}

command -v feh >/dev/null 2>&1 || {
    notify_error "feh is not installed"
    exit 1
}

feh --no-fehbg --bg-fill "$wallpaper" || exit 1

if [ "$1" = --file ]; then
    state_tmp="$state_file.tmp.$$"
    if ! (umask 077; printf '%s\n' "$wallpaper" > "$state_tmp") ||
       ! mv -f -- "$state_tmp" "$state_file"; then
        rm -f -- "$state_tmp"
        notify_error "Wallpaper changed, but the selection could not be saved"
    fi
fi
