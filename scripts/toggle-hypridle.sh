#!/bin/bash

if pgrep -x hypridle >/dev/null; then
    # hypridle is running, kill it
    pkill -x hypridle
    notify-send "Hypridle Toggle" "Hypridle Process Killed!"
else
    # hypridle is not running, start it
    hypridle & disown
    notify-send "Hypridle Toggle" "Hypridle Process Revived."
fi
