#!/bin/bash
_WATCH_EXP="type=signal, \
            sender=org.freedesktop.DBus, \
            path=/org/freedesktop/DBus, \
            interface=org.freedesktop.DBus"           
_MSG='string "org.kde.systemsettings"'


watch_acquisitions() {
    while read event_line; do
        if [ "$event_line" == "$_MSG" ]; then
            polybar-msg hook settings 3
        fi
    done < <(dbus-monitor "$_WATCH_EXP, \
                           member=NameAcquired")
}

watch_losses() {
    while read event_line; do
        if [ "$event_line" == "$_MSG" ]; then
            polybar-msg hook settings 2
        fi
    done < <(dbus-monitor "$_WATCH_EXP, \
                           member=NameLost")
}

watch_acquisitions &
watch_losses &
