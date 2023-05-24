#!/bin/bash

while read event
do
    if echo $event | grep "Event 'change' on server"
    then  
        echo "resetting"
        pkill -USR1 cava
    fi
done < <(pactl subscribe)
