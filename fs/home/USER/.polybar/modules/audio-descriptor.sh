#!/bin/bash

_DIR="${BASH_SOURCE%/*}"
source ${_DIR}/../utils.sh
source ${_DIR}/audio-visualizer/toggle_state.sh
TIMEOUT_SECS=5
TIMER_PID_FILE=/tmp/polybar_audio-descriptor_timer.pid
TIMER_LOCK=/var/lock/polybar_audio-descriptor_timer.lock

DISPLAY_FRACTION=$1


char_limit=$(($(get_num_chars_18 $BAR_MONITOR $DISPLAY_FRACTION) - 3))
echo_truncated() {
    output=${1:0:char_limit}
    if [ ${#1} -gt $char_limit ]
    then
        output="${output}..."
    fi
    
    echo $output
}


timer_pid=0
set_idle_timer() {
    sleep $TIMEOUT_SECS
    
    (
    # acquire lock
    flock 9

    # change audio-visualizer state: idle
    idle
    ) 9> $TIMER_LOCK  # redirect changes on lock file descriptor to lock file
}


get_inputs() {
    # get inputs
    INPUTS_RAW=$(pactl list sink-inputs | grep "application.name = " | cut -d '=' -f 2 | tr -d '"')
    INPUTS=$(echo "$INPUTS_RAW" | head -1)
    while read input
    do  
        INPUTS="${INPUTS} | ${input}"
    done < <(tail +2 < <(echo -e "$INPUTS_RAW"))
    
    # print results
    if [ "$INPUTS" == "" ]
    then
        echo_truncated "(none)"

        {
        # acquire lock. If timer has lock (and is therefore setting idle state), 
        # no need to set another timer; exit
        flock -n 9 || exit 1

        # if no idle timer set, set one
        if [ $timer_pid -eq 0 ]
        then
            set_idle_timer &
            timer_pid=$!
        fi

        # explicitly release lock so that backgrounded processes do not keep file 
        # descriptor open
        flock -u 9
        } 9> $TIMER_LOCK  # redirect changes on lock file descriptor to lock file
    else
        echo_truncated "sink inputs -- ${INPUTS}"

        {
        # acquire lock
        flock 9

        if [ $timer_pid -gt 0 ]
        then
            # if timer running, stop it. Otherwise, timer went off and 
            # audio-visualizer state is idle, so set state: active
            if [ "$(ps -p $timer_pid -o comm=)" == "audio-descriptor.sh" ]
            then
                kill $timer_pid
            else
                active
            fi
            timer_pid=0
        fi
        } 9> $TIMER_LOCK  # redirect changes on lock file descriptor to lock file
    fi
}


# get initial inputs
get_inputs

# update inputs on sink-input change event
while read event
do 
    if [ "$(echo $event | grep "Event '.*' on sink-input")" != "" ]
    then
        get_inputs
    fi
done < <(pactl subscribe)







