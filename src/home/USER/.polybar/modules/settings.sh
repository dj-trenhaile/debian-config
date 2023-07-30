#!/bin/bash

WATCH_EXP="type='signal', \
           sender='org.freedesktop.DBus', \
           path='/org/freedesktop/DBus', \
           interface='org.freedesktop.DBus'"


# set initial value
echo  


watch_acquisitions() {
    while read event_line
    do
        if [ "$event_line" == "string \"org.kde.systemsettings\"" ]
        then
            polybar-msg hook settings 3
        fi
    done < <(dbus-monitor "${WATCH_EXP}, \
                           member='NameAcquired'")
}

watch_losses() {
    while read event_line
    do
        if [ "$event_line" == "string \"org.kde.systemsettings\"" ]
        then
            polybar-msg hook settings 2
        fi
    done < <(dbus-monitor "${WATCH_EXP}, \
                           member='NameLost'")
}

watch_acquisitions &
watch_losses &
