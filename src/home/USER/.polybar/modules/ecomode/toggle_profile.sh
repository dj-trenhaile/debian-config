#!/bin/bash
source ${BASH_SOURCE%/*}/profiles.sh


(
    # acquire compositor launch lock; exit if unavailable
    flock -n 9 || exit 1

    # apply power profile and update module
    if [ "$(powerprofilesctl get)" == "power-saver" ]; then 
        balanced
    else   
        power-saver
    fi

) 9> $_COMPOSITOR_LAUNCH_LOCK  # redirect changes on lock file descriptor to lock file

