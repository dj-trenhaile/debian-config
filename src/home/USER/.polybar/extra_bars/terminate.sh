#!/bin/bash

ps -C polybar -o args:100,pid= | grep extras-secondary | while read process; do
    pid=${process##* }
    if [ "$(strings /proc/$pid/environ | grep BAR_MONITOR | cut -d = -f2)" == "$(get-current-display)" ]; then
        kill $pid
    fi
done
