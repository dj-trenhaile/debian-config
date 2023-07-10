#!/bin/bash

powerprofilesctl set balanced


# other functions
if [ "$(pgrep picom)" == "" ]
then
    picom --config ~/.config/picom/config --fading &
fi
