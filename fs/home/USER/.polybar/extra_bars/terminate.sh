#!/bin/bash

current_display=$(get-current-display)

while read process
do
    pid=$(echo $process | cut -d ' ' -f3)
    if [ "$(strings /proc/${pid}/environ | grep BAR_MONITOR | cut -d '=' -f2)" == $current_display ]
    then
        kill $pid
    fi
done < <(ps -C polybar -o args,pid= | grep "extras-secondary" | tr -s ' ')
