#!/bin/bash

if pgrep -x waybar >/dev/null; then
    # Waybar is running, kill it
    pkill -x waybar
else
    # Waybar is not running, start it
    waybar & disown
fi
