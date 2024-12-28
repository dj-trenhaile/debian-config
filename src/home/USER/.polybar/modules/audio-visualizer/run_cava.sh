#!/bin/bash
CONFIG_PATH=$1


cmd="cava -p \"$CONFIG_PATH\""
eval "$cmd &"

# pulseaudio server state change ==> cava timeout ==> pipe input closure; pipe 
# output remains open, leaving reader in an irrecoverable blocked state; on 
# event, soft reload cava to reinitialze pipe
pactl subscribe | while read event; do
    if [ "$(echo $event | grep "Event 'change' on server")" != "" ]; then
        pkill -USR1 -f "$cmd"
    fi
done
