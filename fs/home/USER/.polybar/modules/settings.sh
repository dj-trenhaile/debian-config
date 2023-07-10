#!/bin/bash

SETTINGS_LOCK=/var/lock/polybar_settings.lock


(
# acquire lock. Only one instance allowed, so exit if unavailable 
flock -n 9 || exit 1

polybar-msg hook settings 2
systemsettings
polybar-msg hook settings 1
) 9> $SETTINGS_LOCK  # redirect changes on lock file descriptor to lock file
