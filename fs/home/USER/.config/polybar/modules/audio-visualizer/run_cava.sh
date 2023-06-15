#!/bin/bash

# cleanup pipe on exit
trap "rm -f $PIPE; exit" SIGTERM

# create pipe
mkfifo $PIPE

# run cava
cava -p $CAVA_CONFIG &

# pulseaudio server state change ==> cava timeout ==> pipe closes;
# force a soft reload on event
while read event
do
    if echo $event | grep "Event 'change' on server"
    then  
        pkill -USR1 cava
    fi
done < <(pactl subscribe)