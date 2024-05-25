#!/bin/bash
_DIR=${BASH_SOURCE%/*}
_OVERLAY=~/.resources/lock.png
_OVERLAY_OFFSETS=/var/tmp/lockscreen_overlay_offsets.txt
_BG=/tmp/screen.png
_RANDR_STATE=/tmp/randr.txt


# ============================================================================ #

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


res=$(xrandr | grep current | sed -E 's/.*current\s([0-9]+)\sx\s([0-9]+).*/\1x\2/')  # TODO: break out
cmd="ffmpeg -f x11grab -video_size $res -y -i $DISPLAY"
filter='[0]boxblur=10:1'

overlay_num=1
while read overlay_offsets; do
    # read overlay offsets
    x_offset=$(echo $overlay_offsets | cut -d x -f1)
    y_offset=$(echo $overlay_offsets | cut -d x -f2)
    
    # add a new image to ffmpeg command
    cmd="$cmd -i $_OVERLAY"
  
    # add offsets to ffmpeg filter
    filter_stage="[o$overlay_num]"
    filter="$filter${filter_stage}\;$filter_stage[$overlay_num]overlay=$x_offset:$y_offset"
  
    overlay_num=$((overlay_num+1))
done < <(cat $_OVERLAY_OFFSETS)

# pause on-screen animations
pid_idle=$(pgrep -f idle.sh)
kill -STOP $pid_idle

# take scrot and apply transformations
cmd="$cmd -filter_complex $filter -vframes 1 $_BG -loglevel quiet"
echo $cmd
eval $cmd

# lock screen
i3lock -i $_BG
# watch for verification via biometrics
while pidof i3lock; do
    if (fprintd-verify | grep verify-match); then 
        killall i3lock
    fi
done

# resume on-screen animations
kill -CONT $pid_idle

# remove processed scrot
rm $_BG

