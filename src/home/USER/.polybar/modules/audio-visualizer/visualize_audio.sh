#!/bin/bash
_DIR=${BASH_SOURCE%/*}
_PIPE=/tmp/cava.$$.fifo
trap "rm $_PIPE; exit" SIGTERM
export _CAVA_CONFIG=/tmp/cava.config
source $_DIR/../../utils.sh
DISPLAY_FRACTION=$1


bars_cnt_raw=$(get_num_chars_26_mono $BAR_MONITOR $DISPLAY_FRACTION) 
export BARS_CNT=$((bars_cnt_raw + (bars_cnt_raw % 2)))


# create "dictionary" to translate cava output =============================== #
# TODO: break out

bar=▁▂▃▄▅▆▇█
dict="s/;//g;"

i=0
while [ $i -lt ${#bar} ]; do
    dict="${dict}s/$i/${bar:$i:1}/g;"
    i=$((i+1))
done

# ======================== #


# run cava =================================================================== #

start_cava() {
    rm -f $_PIPE
    mkfifo $_PIPE
    $_DIR/run_cava.sh &
}

echo "
[general]
bars = $BARS_CNT
autosens = 1
sleep_timer = 3

[output]
method = raw
raw_target = $_PIPE
data_format = ascii
ascii_max_range = $BARS_RANGE
" > $_CAVA_CONFIG
start_cava 
# TODO: laptop sleep bug

# ======================== #


while true; do
    if [ -p $_PIPE ]; then
        # read cava output
        while read -r cmd; do
            echo $cmd | sed $dict
        done < $_PIPE
    
        DICT=$dict ANIM_DELAY=$IDLE_ANIM_DELAY $_DIR/idle.sh
        start_cava
    fi
done

