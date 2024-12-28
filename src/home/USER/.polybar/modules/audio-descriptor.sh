#!/bin/bash
_TIMEOUT_SECS=5
_TIMER_LOCK=/var/lock/polybar_audio-descriptor_timer.lock
_VISUALIZER_STATE_LOCK=/var/lock/polybar_audio-descriptor_visualizer-state.lock
cleanup() {
    rm -f "$_TIMER_LOCK" "$_VISUALIZER_STATE_LOCK"
}
cleanup
trap "cleanup; exit" SIGTERM

dir=${BASH_SOURCE%/*}
source "$dir/../utils.sh"
source "$dir/audio-visualizer/toggle_state.sh"

# see $dir/../utils.sh
DISPLAY_FRACTION=$1
# whether or not to include the prefix in the description
USE_PREFIX=$2


prefix=''
if [ $USE_PREFIX -eq 1 ]; then
    prefix='sink inputs -- '
fi

timer_pid=0
idle_timer() {
    {
        # acquire timer lock
        flock 9

        sleep $_TIMEOUT_SECS
        {
            # acquire state lock
            flock 8

            # set state: idle
            idle

        } 8> $_VISUALIZER_STATE_LOCK  # redirect changes on lock file descriptor to lock file
    } 9> $_TIMER_LOCK  # redirect changes on lock file descriptor to lock file
}

char_limit=$(($(get_num_chars_20_mono "$BAR_MONITOR" $DISPLAY_FRACTION) - 3))
echo_inputs() {
    INPUTS=$1
    
    output="$prefix$INPUTS"
    output_truncated=${output:0:char_limit}
    if [ ${#output} -gt $char_limit ]; then
        output_truncated="$output_truncated..."
    fi
    echo $output_truncated
}

get_inputs() {
    # get inputs
    inputs_raw=$(pactl list sink-inputs | grep 'application.name = ' | cut -d = -f 2 | tr -d '"')
    inputs=$(echo "$inputs_raw" | head -n 1)
    while read input; do
        inputs="$inputs | $input"
    done < <(tail +2 < <(echo "$inputs_raw"))


    # ==================== #
    # print inputs and handle visualizer state changes
    # ==================== #

    if [ "$inputs" == '' ]; then
        echo_inputs '(none)'

        {
            # attempt to acquire state lock
            flock -n 9
            if [ $? -eq 0 ]; then
                
                # if no timer active, set one 
                if [ $timer_pid -eq 0 ]; then
                    idle_timer &
                    timer_pid=$!
                    # manually release lock (file descriptor passed to timer process)
                    flock -u 9
                fi
            
            else
                # lock acquisition failed ==> timer triggered and will set state: idle; acquire 
                # state lock
                flock 9

                # reset timer_pid
                timer_pid=0
            fi

        } 9> $_VISUALIZER_STATE_LOCK  # redirect changes on lock file descriptor to lock file
    
    else
        echo_inputs "$inputs"   

        {
            # attempt to acquire visualizer state lock
            flock -n 9
            if [ $? -eq 0 ]; then
                
                if [ $timer_pid -gt 0 ]; then
                    {
                        (
                            # attempt to acquire timer lock
                            flock -n 8 || exit 1
                            
                            # timer triggered before visualizer state lock acquisition ==> current
                            # state is idle; set state: active
                            active
                            
                        ) 8> $_TIMER_LOCK  # redirect changes on lock file descriptor to lock file

                    } || {
                        # lock acquisition failed ==> timer running (will block at state change 
                        # since state lock is acquired); kill timer
                        kill $timer_pid
                    }

                    # reset timer_pid
                    timer_pid=0
                fi
            
            else
                # lock acquisition failed ==> timer triggered, state is being set: idle; acquire 
                # state lock
                flock 9

                # set state: active
                active
                # reset timer_pid
                timer_pid=0
            fi
            
        } 9> $_VISUALIZER_STATE_LOCK  # redirect changes on lock file descriptor to lock file
    fi
}


# get initial inputs
get_inputs  

# update inputs on sink-input change event
while read event; do
    if [ "$(echo $event | grep "Event '.*' on sink-input")" != '' ]; then
        get_inputs
    fi
done < <(pactl subscribe)
