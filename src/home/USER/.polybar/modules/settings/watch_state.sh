#!/bin/bash
_WATCH_EXP="type=signal, \
            sender=org.freedesktop.DBus, \
            path=/org/freedesktop/DBus, \
            interface=org.freedesktop.DBus"           
_MSG='string "org.kde.systemsettings"'


watch_acquisitions() {
    dbus-monitor "$_WATCH_EXP, \
                  member=NameAcquired" | 
    
    while read event_line; do
        if [ "$event_line" == "$_MSG" ]; then
            polybar-msg hook settings 3
        fi
    done
}

watch_losses() {
    dbus-monitor "$_WATCH_EXP, \
                  member=NameLost" | 
    
    while read event_line; do
        if [ "$event_line" == "$_MSG" ]; then
            polybar-msg hook settings 2
        fi
    done
}


watch_acquisitions &
watch_losses &
