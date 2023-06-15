#!/bin/bash

MAX_EMPTY_ITS=3
SECS_BETWEEN_ITS=2


empty_its=0
idling=0

while true
do 
    # get inputs
    INPUTS_RAW=$(pactl list sink-inputs | grep "application.name = " | cut -d '=' -f 2 | tr -d '"')
    INPUTS=$(echo "$INPUTS_RAW" | head -1)
    n=0
    while read input
    do  
        if [ $n -eq 0 ]
        then
            n=1
        else
            INPUTS="${INPUTS} | ${input}"
        fi
    done < <(echo "$INPUTS_RAW")

    # print results
    if [ "$INPUTS" == "" ]
    then
        echo "(none)"
        empty_its=$((empty_its+1))
    else
        echo $INPUTS
        empty_its=0
    fi

    # check for audio timeout; update running cava instance(s) accordingly
    if [ $empty_its -gt $MAX_EMPTY_ITS ]
    then      
        if [ $idling -eq 0 ]
        then
            pkill -USR1 -f "audio-visualizer/listener"
            idling=1
        fi
    else
        if [ $idling -eq 1 ]
        then
            pkill -USR2 -f "audio-visualizer/listener"
            idling=0
        fi
    fi
    
    sleep $SECS_BETWEEN_ITS

done