#!/bin/sh

set -eu

theme_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
config_home=${XDG_CONFIG_HOME:-"$HOME/.config"}
apps="alacritty dunst i3 i3blocks picom polybar rofi"
timestamp=$(date '+%Y%m%d-%H%M%S')
backup_parent="$config_home/backups"
backup_dir=
backup_created=0
moved_apps=
linked_apps=

fail() {
    printf 'link-configs: %s\n' "$1" >&2
    exit 1
}

for app in $apps; do
    [ -d "$theme_dir/$app" ] || fail "missing theme directory: $theme_dir/$app"
done

mkdir -p "$config_home"

rollback() {
    status=$?
    trap - 0 HUP INT TERM
    set +e

    for app in $linked_apps; do
        target="$config_home/$app"
        source="$theme_dir/$app"
        if [ -L "$target" ] && [ "$(readlink "$target")" = "$source" ]; then
            unlink "$target"
        fi
    done

    for app in $moved_apps; do
        if [ -e "$backup_dir/$app" ] || [ -L "$backup_dir/$app" ]; then
            mv -- "$backup_dir/$app" "$config_home/$app"
        fi
    done

    printf 'link-configs: failed; original paths were restored\n' >&2
    exit "$status"
}

trap rollback 0 HUP INT TERM

for app in $apps; do
    source="$theme_dir/$app"
    target="$config_home/$app"

    if [ -L "$target" ] && [ "$(readlink "$target")" = "$source" ]; then
        continue
    fi

    if [ -e "$target" ] || [ -L "$target" ]; then
        if [ "$backup_created" -eq 0 ]; then
            mkdir -p "$backup_parent"
            backup_dir=$(mktemp -d "$backup_parent/i3-transparent-$timestamp.XXXXXX")
            backup_created=1
        fi
        mv -- "$target" "$backup_dir/$app"
        moved_apps="$app $moved_apps"
    fi

    ln -s -- "$source" "$target"
    linked_apps="$app $linked_apps"
done

if [ "$backup_created" -eq 1 ] && [ -d "$backup_dir/i3" ]; then
    for runtime_file in wallpaper xkb-layout; do
        [ -e "$backup_dir/i3/$runtime_file" ] || continue
        cp -a -- "$backup_dir/i3/$runtime_file" "$theme_dir/i3/$runtime_file"
    done
fi

trap - 0 HUP INT TERM

printf 'Active configs now point to %s\n' "$theme_dir"
if [ "$backup_created" -eq 1 ]; then
    printf 'Backup: %s\n' "$backup_dir"
else
    printf 'No backup was needed.\n'
fi
