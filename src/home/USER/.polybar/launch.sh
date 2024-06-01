#!/bin/bash

# generate and set variables
${BASH_SOURCE%/*}/generate_vars.sh
set -a
source $_POLYBAR_VARS
set +a

{
    # acquire lock
    flock 9

    # kill any lingering bars
    polybar-msg cmd quit

    # start bars
    PRIMARY=$(xrandr -q | grep ' primary' | cut -d ' ' -f1)
    for m in $(xrandr -q | grep ' connected' | cut -d ' ' -f1); do
        if [ "$m" == "$PRIMARY" ]; then
            BAR_MONITOR=$m polybar utils-primary &
            BAR_MONITOR=$m polybar extras &
        else
            BAR_MONITOR=$m polybar utils-secondary &
        fi
    done

    # explicitly release lock so that backgrounded processes do not keep file 
    # descriptor open
    flock -u 9
    
 } 9> $_POLYBAR_LAUNCH_LOCK  # redirect changes on lock file descriptor to lock file
