#!/bin/sh

set -eu

theme_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
config_home=${XDG_CONFIG_HOME:-"$HOME/.config"}
wallpaper_target=${WALLPAPER_DIR:-"$HOME/Pictures/Wallpapers"}
wallpaper_source="$theme_dir/wallpapers"
linker="$theme_dir/link-configs.sh"
helper_source="$theme_dir/i3/xkb-layout.c"
timestamp=$(date '+%Y%m%d-%H%M%S')
helper_tmp=
wallpaper_backup=
wallpaper_linked=0

fail() {
    printf 'install: %s\n' "$1" >&2
    exit 1
}

[ -x "$linker" ] || fail "missing executable: $linker"
[ -d "$wallpaper_source" ] || fail "missing wallpaper directory: $wallpaper_source"
[ -r "$helper_source" ] || fail "missing XKB helper source: $helper_source"
command -v cc >/dev/null 2>&1 || fail "a C compiler is required"

case $wallpaper_target in
    "$theme_dir"|"$theme_dir"/*)
        fail "WALLPAPER_DIR must not point inside the theme repository"
        ;;
esac

helper_tmp=$(mktemp "${TMPDIR:-/tmp}/i3-xkb-layout.XXXXXX")

rollback() {
    status=$?
    trap - 0 HUP INT TERM
    set +e

    [ -n "$helper_tmp" ] && rm -f -- "$helper_tmp"

    if [ "$wallpaper_linked" -eq 1 ] && [ -L "$wallpaper_target" ] &&
       [ "$(readlink "$wallpaper_target")" = "$wallpaper_source" ]; then
        unlink "$wallpaper_target"
    fi

    if [ -n "$wallpaper_backup" ] &&
       { [ -e "$wallpaper_backup" ] || [ -L "$wallpaper_backup" ]; }; then
        mkdir -p "$(dirname -- "$wallpaper_target")"
        mv -- "$wallpaper_backup" "$wallpaper_target"
    fi

    printf 'install: failed; the wallpaper path was restored\n' >&2
    exit "$status"
}

trap rollback 0 HUP INT TERM

# Compile before changing active paths so missing Xlib headers fail safely.
cc -O2 -Wall -Wextra -pedantic -o "$helper_tmp" "$helper_source" -lX11

"$linker"

if ! { [ -L "$wallpaper_target" ] &&
       [ "$(readlink "$wallpaper_target")" = "$wallpaper_source" ]; }; then
    if [ -e "$wallpaper_target" ] || [ -L "$wallpaper_target" ]; then
        backup_parent="$config_home/backups"
        mkdir -p "$backup_parent"
        backup_dir=$(mktemp -d "$backup_parent/i3-transparent-wallpapers-$timestamp.XXXXXX")
        wallpaper_backup="$backup_dir/Wallpapers"
        mv -- "$wallpaper_target" "$wallpaper_backup"
    fi

    mkdir -p "$(dirname -- "$wallpaper_target")"
    ln -s -- "$wallpaper_source" "$wallpaper_target"
    wallpaper_linked=1
fi

install -m 755 -- "$helper_tmp" "$config_home/i3/xkb-layout"

trap - 0 HUP INT TERM
rm -f -- "$helper_tmp"

printf 'Theme installed from %s\n' "$theme_dir"
printf 'Wallpapers: %s -> %s\n' "$wallpaper_target" "$wallpaper_source"
if [ -n "$wallpaper_backup" ]; then
    printf 'Wallpaper backup: %s\n' "$(dirname -- "$wallpaper_backup")"
fi
