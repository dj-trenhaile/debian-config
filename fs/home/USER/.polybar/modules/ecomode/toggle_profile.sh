#!/bin/bash

_DIR="${BASH_SOURCE%/*}"


source ${_DIR}/profiles.sh

(
# acquire compositor launch lock; exit if unavailable
flock -n 9 || exit 1

if [ "$(powerprofilesctl get)" == "power-saver" ]
then   
    balanced
else   
    power-saver
fi
) 9> $COMPOSITOR_LAUNCH_LOCK  # redirect changes on lock file descriptor to lock file

