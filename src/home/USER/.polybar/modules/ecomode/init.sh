#!/bin/bash

_DIR=${BASH_SOURCE%/*}


# check that battery exists
if [ "$BAR_BATTERY" == "" ]
then
    exit 1
fi

# import power profiles
source ${_DIR}/profiles.sh

# set initial module state 
echo "%{F$COLOR_DISABLED}unavailable%{F-}"

(
# acquire compositor launch lock
flock 9

# apply power profile and update module
if [ "$(powerprofilesctl get)" == "power-saver" ]
then
    power-saver
else
    balanced
fi
) 9> $COMPOSITOR_LAUNCH_LOCK  # redirect changes on lock file descriptor to lock file
