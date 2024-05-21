#!/bin/bash

powerprofilesctl set balanced
if [ "$(pgrep picom)" == '' ]; then
    picom --config ~/.config/picom/config --fading &
fi

