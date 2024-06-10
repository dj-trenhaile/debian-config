#!/bin/bash
source ${BASH_SOURCE%/*}/profiles.sh


{
    # attempt to acquire compositor launch lock
    flock -n 9 && {

        # apply power profile and update module
        if [ "$(powerprofilesctl get)" == 'power-saver' ]; then 
            balanced
        else   
            power-saver
        fi
    }

 } 9> $_COMPOSITOR_LAUNCH_LOCK  # redirect changes on lock file descriptor to lock file
