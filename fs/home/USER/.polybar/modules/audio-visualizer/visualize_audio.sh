#!/bin/bash

_DIR="${BASH_SOURCE%/*}"
source ${_DIR}/../../utils.sh
export PIPE=/tmp/cava.$$.fifo
export CAVA_CONFIG=/tmp/cava.$$.config

DISPLAY_FRACTION=$1


# get number of bars ======================================================
BARS_CNT=$(get_num_chars_22 $BAR_MONITOR $DISPLAY_FRACTION)  


# create "dictionary" to translate cava output =============================== #
bar="▁▂▃▄▅▆▇█"
dict="s/;//g;"

i=0
while [ $i -lt ${#bar} ]
do
    dict="${dict}s/$i/${bar:$i:1}/g;"
    i=$((i+1))
done


# run cava =================================================================== #
echo "

[general]
bars = $BARS_CNT

[output]
method = raw
raw_target = $PIPE
data_format = ascii
ascii_max_range = $BARS_RANGE

" > $CAVA_CONFIG

rm -f $PIPE
${_DIR}/run_cava.sh &


# main loop ================================================================== #
while true
do
    if [ -p $PIPE ]
    then
        # read cava output
        while read -r cmd; do
            echo $cmd | sed $dict
        done < $PIPE
    
        DICT=$dict ANIM_DELAY=$IDLE_ANIM_DELAY ${_DIR}/idle.sh
        ${_DIR}/run_cava.sh &
    fi
done



 