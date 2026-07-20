#include <X11/XKBlib.h>

#include <stdio.h>
#include <string.h>

static int read_state(Display *display, XkbStateRec *state)
{
    if (XkbGetState(display, XkbUseCoreKbd, state) == Success)
        return 1;

    fputs("xkb-layout: unable to read XKB state\n", stderr);
    return 0;
}

int main(int argc, char **argv)
{
    Display *display;
    XkbStateRec state;
    unsigned int group;
    int toggle = 0;

    if (argc > 2 || (argc == 2 && strcmp(argv[1], "get") != 0 &&
                     strcmp(argv[1], "toggle") != 0)) {
        fprintf(stderr, "Usage: %s [get | toggle]\n", argv[0]);
        return 2;
    }

    if (argc == 2 && strcmp(argv[1], "toggle") == 0)
        toggle = 1;

    display = XOpenDisplay(NULL);
    if (display == NULL) {
        fputs("xkb-layout: unable to open X display\n", stderr);
        return 1;
    }

    if (!read_state(display, &state)) {
        XCloseDisplay(display);
        return 1;
    }

    group = state.group;
    if (toggle) {
        group = group == 0 ? 1 : 0;
        if (!XkbLockGroup(display, XkbUseCoreKbd, group)) {
            fputs("xkb-layout: unable to switch XKB group\n", stderr);
            XCloseDisplay(display);
            return 1;
        }
        XSync(display, False);
    }

    puts(group == 1 ? "RU" : "EN");
    XCloseDisplay(display);
    return 0;
}
