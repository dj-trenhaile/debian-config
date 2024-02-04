#!/bin/bash

# TODO: trap "<rm locks>; exit" SIGTERM

_DIR=${BASH_SOURCE%/*}
source ${_DIR}/../utils.sh
source ${_DIR}/audio-visualizer/toggle_state.sh
TIMEOUT_SECS=5
TIMER_LOCK="/tmp/polybar_audio-descriptor_timer.$$.lock"
VISUALIZER_STATE_LOCK="/tmp/polybar_audio-descriptor_visualizer-state.$$.lock"
trap "rm $TIMER_LOCK; rm $VISUALIZER_STATE_LOCK; exit" SIGTERM

DISPLAY_FRACTION=$1
USE_PREFIX=$2


prefix="sink inputs -- "
if [ $USE_PREFIX -eq 0 ]; then
    prefix=""
fi

timer_pid=0
idle_timer() {
    {
        # acquire timer lock
        flock 9

        sleep $TIMEOUT_SECS
        {
            # acquire visualizer state lock
            flock 8

            # set audio-visualizer state: idle
            idle            
        } 8> $VISUALIZER_STATE_LOCK  # redirect changes on lock file descriptor to lock file
    } 9> $TIMER_LOCK  # redirect changes on lock file descriptor to lock file
}

char_limit=$(($(get_num_chars_20_mono $BAR_MONITOR $DISPLAY_FRACTION) - 3))
echo_inputs() {
    output="${prefix}${1}"
    output_truncated=${output:0:char_limit}
    if [ ${#output} -gt $char_limit ]; then
        output_truncated="${output_truncated}..."
    fi
    
    echo $output_truncated
}

get_inputs() {
    # get inputs
    inputs_raw=$(pactl list sink-inputs | grep "application.name = " | cut -d '=' -f 2 | tr -d '"')
    inputs=$(echo "$inputs_raw" | head -1)
    while read input; do
        inputs="${inputs} | ${input}"
    done < <(tail +2 < <(echo -e "$inputs_raw"))

    # print results and handle visualizer state changes
    if [ "$inputs" == "" ]; then
        echo_inputs "(none)"
        
        {
            {
                # attempt to acquire visualizer state lock
                flock -n 9

                # if no timer active, set one 
                if [ $timer_pid -eq 0 ]; then
                    idle_timer &
                    timer_pid=$!
                    # manually release lock (file descriptor passed to timer process)
                    flock -u 9
                fi
            } || {
                # lock acquisition failed ==> timer triggered, state is being set to idle.
                # acquire visualizer state lock
                flock 9

                # reset timer_pid
                timer_pid=0
            }
        } 9> $VISUALIZER_STATE_LOCK  # redirect changes on lock file descriptor to lock file
    else
        echo_inputs "$inputs"   

        {
            {
                # attempt to acquire visualizer state lock
                flock -n 9

                if [ $timer_pid -gt 0 ]; then
                    {
                        {
                            # attempt to acquire timer lock
                            flock -n 8
                            
                            # timer triggered before visualizer state lock acquisition. Current
                            # state is idle.
                            # set audio-visualizer state: active
                            active
                        } || {
                            # lock acquisition failed ==> timer running
                            # (will block at state change since visualizer state lock is acquired).
                            # kill timer
                            kill $timer_pid
                        }
                        
                        # reset timer_pid
                        timer_pid=0
                    } 8> $TIMER_LOCK  # redirect changes on lock file descriptor to lock file
                fi
            } || {
                # lock acquisition failed ==> timer triggered, state is being set to idle.
                # acquire visualizer state lock
                flock 9

                # set audio-visualizer state: active
                active
                # reset timer_pid
                timer_pid=0
            }
        } 9> $VISUALIZER_STATE_LOCK  # redirect changes on lock file descriptor to lock file
    fi
}


# get initial inputs
get_inputs  

# update inputs on sink-input change event
while read event; do
    if [ "$(echo $event | grep "Event '.*' on sink-input")" != "" ]; then
        get_inputs
    fi
done < <(pactl subscribe)
