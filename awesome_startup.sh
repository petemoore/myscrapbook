#!/bin/bash

function run_one {
    pgrep "${1}" || "${@}" &
}

SCREENS="$(xrandr | sed -n 's/\(.*\) connected.*/\1/p')"

if echo "${SCREENS}" | grep -Fx 'eDP-2' >/dev/null 2>&1 && echo "${SCREENS}" | grep -Fx 'HDMI-1' >/dev/null 2>&1
then
    # both screens attached, so let's enable one above the other (not cloned screens)
    xrandr --output 'HDMI-1' --above 'eDP-2'
fi

run_one 'nm-applet'
run_one 'gnome-settings-daemon'
run_one 'gnome-sound-applet'
run_one 'firefox'
run_one 'xchat'
run_one 'skype'
run_one 'thunderbird'
run_one 'rhythmbox'
run_one 'spotify'
run_one 'gnome-terminal'
run_one 'xscreensaver'
