#!/bin/bash

cmd="cava -p $_CAVA_CONFIG"
eval "$cmd &"

# pulseaudio server state change ==> cava timeout ==> pipe input closure; pipe 
# output remains open, leaving reader in an irrecoverable blocked state; on 
# event, soft reload cava to reinitialze pipe
while read event; do
    if [ "$(echo $event | grep "Event 'change' on server")" != "" ]; then
        pkill -USR1 -f "$cmd"
    fi
done < <(pactl subscribe)
