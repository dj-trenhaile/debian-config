#!/bin/bash
_DIR=${BASH_SOURCE%/*}
source ${_DIR}/../../utils.sh
export PIPE=/tmp/cava.$$.fifo
trap "rm $PIPE; exit" SIGTERM
export CAVA_CONFIG=/tmp/cava.config

DISPLAY_FRACTION=$1


# get number of bars ======================================================
bars_cnt_raw=$(get_num_chars_26_mono $BAR_MONITOR $DISPLAY_FRACTION) 
export BARS_CNT=$((bars_cnt_raw + (bars_cnt_raw % 2)))


# create "dictionary" to translate cava output =============================== #
bar="▁▂▃▄▅▆▇█"
dict="s/;//g;"

i=0
while [ $i -lt ${#bar} ]; do
    dict="${dict}s/$i/${bar:$i:1}/g;"
    i=$((i+1))
done


start_cava() {
    rm -f $PIPE
    mkfifo $PIPE
    ${_DIR}/run_cava.sh &
}


# run cava =================================================================== #
echo "
[general]
bars = $BARS_CNT
autosens = 1
sleep_timer = 3

[output]
method = raw
raw_target = $PIPE
data_format = ascii
ascii_max_range = $BARS_RANGE
" > $CAVA_CONFIG
start_cava 
# TODO: laptop sleep bug


# main loop ================================================================== #
while true; do
    if [ -p $PIPE ]; then
        # read cava output
        while read -r cmd; do
            echo $cmd | sed $dict
        done < $PIPE
    
        DICT=$dict ANIM_DELAY=$IDLE_ANIM_DELAY ${_DIR}/idle.sh
        start_cava
    fi
done
