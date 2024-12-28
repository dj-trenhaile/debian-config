#!/bin/bash
_DIR=${BASH_SOURCE%/*}
_PIPE=/tmp/cava.$$.fifo
cleanup() {
    rm -f $_PIPE
}
trap "cleanup; exit" SIGTERM
_CAVA_CONFIG=/tmp/cava.config

source "$_DIR/../../utils.sh"

DISPLAY_FRACTION=$1


bars_cnt_raw=$(get_num_chars_26_mono $BAR_MONITOR $DISPLAY_FRACTION) 
bars_cnt=$((bars_cnt_raw + (bars_cnt_raw % 2)))


# create "dictionary" to translate cava output =============================== #

bar=▁▂▃▄▅▆▇█
dict="s/;//g;"  # TODO

i=0
while [ $i -lt ${#bar} ]; do
    dict="${dict}s/$i/${bar:$i:1}/g;"
    ((i++))
done

# ======================== #


# run cava =================================================================== #

start_cava() {
    cleanup
    mkfifo $_PIPE
    $_DIR/run_cava.sh $_CAVA_CONFIG &
}

echo "
[general]
bars = $bars_cnt
autosens = 1
sleep_timer = 3

[output]
method = raw
raw_target = $_PIPE
data_format = ascii
ascii_max_range = $BARS_RANGE
" > $_CAVA_CONFIG
start_cava 

# ======================== #


# TODO: laptop sleep bug

while true; do
    if [ -p $_PIPE ]; then
        
        # read cava output
        while read -r cmd; do
            echo $cmd | sed $dict
        done < $_PIPE
    
        $_DIR/idle.sh $bars_cnt $dict $IDLE_ANIM_DELAY
        start_cava
    fi
done
