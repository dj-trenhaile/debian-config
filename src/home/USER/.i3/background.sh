#!/bin/bash
_SPLASH_TIME=1  # in seconds


(
    # acquire lock
    flock 9
    
    picom --config ~/.config/picom/config --fading &
    sleep $_SPLASH_TIME
    nitrogen --restore
    pkill ksplashqml
    
    # explicitly release lock so that backgrounded processes do not keep file 
    # descriptor open
    flock -u 9
) 9> $COMPOSITOR_LAUNCH_LOCK  # redirect changes on lock file descriptor to lock file

