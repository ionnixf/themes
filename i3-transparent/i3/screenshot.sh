#!/bin/sh

screenshot_dir=${SCREENSHOT_DIR:-"$HOME/Pictures/Screenshots"}
timestamp=$(date '+%Y-%m-%d_%H-%M-%S')
output="$screenshot_dir/$timestamp.png"

notify_error() {
    command -v notify-send >/dev/null 2>&1 && notify-send "Screenshot" "$1"
    printf '%s\n' "$1" >&2
}

command -v import >/dev/null 2>&1 || {
    notify_error "ImageMagick import is not installed"
    exit 1
}

mkdir -p "$screenshot_dir" || {
    notify_error "Unable to create screenshot directory"
    exit 1
}

case ${1:-} in
    full)
        import -window root "$output"
        ;;
    selection)
        import "$output"
        ;;
    window)
        command -v xprop >/dev/null 2>&1 || {
            notify_error "xprop is not installed"
            exit 1
        }
        window_id=$(xprop -root _NET_ACTIVE_WINDOW 2>/dev/null | awk '{ print $NF }')
        case $window_id in
            0x0|0x00000000|'')
                notify_error "Unable to determine the focused window"
                exit 1
                ;;
            0x*) import -window "$window_id" "$output" ;;
            *)
                notify_error "Invalid focused window ID"
                exit 1
                ;;
        esac
        ;;
    *)
        printf 'Usage: %s full | selection | window\n' "$0" >&2
        exit 2
        ;;
esac

if [ "$?" -ne 0 ] || [ ! -s "$output" ]; then
    rm -f -- "$output"
    exit 1
fi

command -v notify-send >/dev/null 2>&1 && \
    notify-send -a "Screenshot" -i "$output" "Screenshot saved" "$output"
