#!/bin/bash

PRIMARY=$(xrandr -q | grep " primary" | cut -d ' ' -f1)
for m in $(xrandr -q | grep " connected" | cut -d ' ' -f1)
do
    BAR="utils-secondary"
    if [ "$m" == "$PRIMARY" ]
    then
        BAR_MONITOR=$m polybar "utils-primary" &
        BAR_MONITOR=$m polybar "extras" &
    else
        BAR_MONITOR=$m polybar "utils-secondary" &
    fi
done
