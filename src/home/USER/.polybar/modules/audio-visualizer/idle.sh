#!/bin/bash

trap "QUIT=1" SIGTERM

# TODO: cache wave calculations

# init visualizer values to zeroes
bar_values=()
i=0
while [ $i -lt $BARS_CNT ]; do
    bar_values+=(0)
    i=$((i+1))
done

# define wave start idx s.t. whole wave starts out of bar
wave_start_idx=$((-BARS_RANGE))
crest_idx=$wave_start_idx
# highest index of the visualizer
top_idx=$((BARS_CNT - 1))

# print current bar values
print_visualizer() {
    bar_values_translated=""
    i=0
    while [ $i -lt $BARS_CNT ]; do
        bar_values_translated="${bar_values_translated}${bar_values[i]};"
        i=$((i+1))
    done
    echo $bar_values_translated | sed $DICT
}

# main animation loop ======================================================== # 
QUIT=0
while [ $QUIT -eq 0 ]; do
    # decrement lower idxs
    if [ $crest_idx -ge 0 ]; then
        low_idx=$((crest_idx - (BARS_RANGE - 1)))
        if [ $low_idx -lt 0 ]; then
            low_idx=0
        fi
        high_idx=$crest_idx
        if [ $high_idx -ge $BARS_CNT ]; then
            high_idx=$top_idx
        fi

        i=$low_idx
        while [ $i -le $high_idx ]; do
            bar_values[$i]=$((bar_values[i] - 1))
            i=$((i+1))
        done
    fi
    
    # increment higher idxs
    if [ $crest_idx -lt $top_idx ]; then
        low_idx=$((crest_idx + 1))
        if [ $low_idx -lt 0 ]; then
            low_idx=0
        fi
        high_idx=$((crest_idx + BARS_RANGE))
        if [ $high_idx -ge $BARS_CNT ]; then
            high_idx=$top_idx
        fi

        i=$low_idx
        while [ $i -le $high_idx ]; do
            bar_values[$i]=$((bar_values[i] + 1))
            i=$((i+1))
        done
    fi

    # print result
    print_visualizer

    # implement speed modifier
    sleep $ANIM_DELAY
    
    # increment crest_idx; reset if animation cycle finished
    crest_idx=$((crest_idx+1))
    if [ $crest_idx -ge $((top_idx + BARS_RANGE)) ]; then
        crest_idx=$wave_start_idx
    fi

done

# $1: crest_idx
# $2: range
get_bounds() {
    offset=$(($2 - 1))

    low_idx=$(($1 - offset))
    high_idx=$(($1 + offset))
}

crest_value=$BARS_RANGE
range=$BARS_RANGE
get_bounds $crest_idx $range

if [ $high_idx -ge 0 ]; then
    # shutdown animation loop ================================================ #
    while [ $low_idx -le $top_idx ] && [ $crest_value -gt 0 ]; do
        new_crest_idx=$((crest_idx + 2))
        new_crest_value=$((crest_value - 1))
        new_range=$((range - 1))
        get_bounds $new_crest_idx $new_range

        if [ $low_idx -le 0 ]; then
            low_idx=0
        else
            # zero 3 old columns (crest_idx += 2, range -= 1)
            
            i=$((low_idx - 1))
            lower_bound=$((i-2))  # inclusive
            if [ $lower_bound -lt 0 ]; then
                lower_bound=0
            fi
            
            while [ $i -ge $lower_bound ]; do
                bar_values[$i]=0
                i=$((i-1))
            done
        fi

        # set crest value
        if [ $new_crest_idx -le $top_idx ] && [ $new_crest_idx -ge 0 ]; then
            bar_values[$new_crest_idx]=$new_crest_value
        fi

        # decrement lower idxs
        if [ $new_crest_idx -gt 0 ]; then
            # low_idx already 0-floored

            idx=$((new_crest_idx - 1))
            value=$((new_crest_value - 1))
            while [ $idx -ge $low_idx ]; do
                bar_values[$idx]=$value

                idx=$((idx-1))
                value=$((value-1))
            done
        fi

        # decrement higher idxs
        if [ $new_crest_idx -lt $top_idx ]; then
            if [ $high_idx -gt $top_idx ]; then
                high_idx=$top_idx
            fi

            idx=$((new_crest_idx + 1))
            value=$((new_crest_value - 1))
            while [ $idx -le $high_idx ]; do
                bar_values[$idx]=$value

                idx=$((idx+1))
                value=$((value-1))
            done
        fi

        # print results
        print_visualizer

        # implement speed modifier
        sleep $ANIM_DELAY

        # set values for next iteration
        crest_idx=$new_crest_idx
        crest_value=$new_crest_value
        range=$new_range
    done
fi




    























    