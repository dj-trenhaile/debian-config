#!/bin/bash
_RANDR_STATE=/tmp/randr.txt
_OVERLAY_OFFSETS=/tmp/lockscreen_overlay_offsets.txt
_OVERLAY=~/.resources/lock.png
_BG=/tmp/screen.png


# init post-unlock function
pid_idle=$(pgrep -f idle.sh)
cont_visualizer_idle() {
    kill -CONT $pid_idle
}

if [ "$pid_idle" == '' ]; then
    # visualizer not idle; pause audio and set post-unlock function to void

    playerctl pause
    cont_visualizer_idle() { : ; }

else
    # visualizer idle; stop visualizer idle animation
    
    kill -STOP $pid_idle
fi


# generate and cache overlay offsets ========================================= #

write_overlay_offsets() {  
    rm -f $_OVERLAY_OFFSETS

    # get overlay image resolution 
    overlay_res=$(file $_OVERLAY | cut -d , -f2 | tr -d ' ')
    overlay_x=$(echo $overlay_res | cut -d x -f1)
    overlay_y=$(echo $overlay_res | cut -d x -f2)

    # for each display, calculate total screen offset of overlay image
    while read display; do
        geometry=$(echo $display | cut -d ' ' -f3)

        resolution=$(echo $geometry | cut -d + -f1)
        width=$(echo $resolution | cut -d x -f1 | cut -d / -f1)
        height=$(echo $resolution | cut -d x -f2 | cut -d / -f1)
  
        x_offset=$(echo $geometry | cut -d + -f2)
        y_offset=$(echo $geometry | cut -d + -f3)
  
        overlay_x_offset=$((x_offset + (width / 2) - (overlay_x / 2)))
        overlay_y_offset=$((y_offset + (height / 2) - (overlay_y / 2)))
        echo ${overlay_x_offset}x${overlay_y_offset} >> $_OVERLAY_OFFSETS

    done < <(tail -n +2 < <(echo "$randr_state"))  # skip first line
}

randr_state=$(xrandr --listactivemonitors)
if [ "$randr_state" == "$(cat $_RANDR_STATE 2> /dev/null)" ]; then
    # randr state not changed; unless offsets file not found, do not regenerate
    if [ ! -f $_OVERLAY_OFFSETS ]; then
        write_overlay_offsets
    fi
else
    # randr state changed; write new state and generate new offsets file
    echo "$randr_state" > $_RANDR_STATE
    write_overlay_offsets
fi

# ======================== #


# take transformed scrot ===================================================== #

# init cmd
current_screen=$(xrandr | grep current)
cmd="ffmpeg -f x11grab -video_size $(echo $current_screen | cut -d ' ' -f8)x\
$(echo $current_screen | cut -d ' ' -f10 | cut -d , -f1) -y -i $DISPLAY"

# init filter
filter='[0]boxblur=10:1'

overlay_num=1
while read overlay_offsets; do
    # add another overlay to ffmpeg cmd
    cmd="$cmd -i $_OVERLAY"
    
    # read overlay offsets
    x_offset=$(echo $overlay_offsets | cut -d x -f1)
    y_offset=$(echo $overlay_offsets | cut -d x -f2)
  
    # add overlay offsets to ffmpeg filter
    filter_stage="[o$overlay_num]"
    filter="$filter${filter_stage}\;$filter_stage[$((overlay_num++))]overlay=$x_offset:$y_offset"

done < <(cat $_OVERLAY_OFFSETS)

cmd="$cmd -filter_complex $filter -vframes 1 $_BG -loglevel quiet"
eval $cmd

# ======================== #


# TODO: revert to i3lock + modified PAM

i3lock -i $_BG -n
cont_visualizer_idle

# qdbus org.freedesktop.ScreenSaver /ScreenSaver Lock
# while read event_line; do
#     if [ "$event_line" == 'boolean false' ]; then
#         echo restarting
#         cont_visualizer_idle
#         break
#     fi
# done < <(dbus-monitor "type=signal, \
#                        path=/ScreenSaver, \
#                        interface=org.freedesktop.ScreenSaver, \
#                        member=ActiveChanged")
