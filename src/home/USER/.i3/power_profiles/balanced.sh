#!/bin/bash

powerprofilesctl set balanced
if [ "$(pgrep -f picom)" == '' ]; then
    picom --config ~/.config/picom/config --fading &
fi
