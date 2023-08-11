#!/bin/bash


# Given a randr display identifier, a fraction, and a monospace font 
# width (pts), return the number of characters (floored to the first integer) 
# that can fit within the fraction of one row of the display 
get_num_chars() {
    DISPLAY_ID=$1
    DISPLAY_FRACTION=$2
    FONT_WIDTH=$3

    display_header=$(xrandr | grep $DISPLAY_ID)    
    display_dims=$(echo $display_header | tr ' ' '\n' | grep mm)

    # get display width (mm)
    display_props=$(echo $display_header | cut -d '(' -f1)
    # echo $display_props
    # echo $display_props | grep "right"
    if [ "$(echo $display_props | grep "right")" == "" ] && \
       [ "$(echo $display_props | grep "left")" == "" ]
    then 
        width_mm=$(echo -e "$display_dims" | head -n 1)
    else
        width_mm=$(echo -e "$display_dims" | tail -n 1)
    fi
    width_mm=$(echo $width_mm | tr -d 'm')

    # convert width to pts, scale by fraction, and convert to num of chars;
    # 1 in / 24.5 mm, 72 pts / in, 1 char / FONT_WIDTH pts
    num_chars=$(bc -l <<< "((${width_mm} / 25.4) * 72 * ${DISPLAY_FRACTION}) / ${FONT_WIDTH}")  

    # return num_chars floored to integer
    echo $(bc <<< "scale=0; ${num_chars} / 1")
}

# get_num_chars wrapper for 26-pt monospaced font
get_num_chars_26_mono() {
    FONT_WIDTH=8.39
    get_num_chars $1 $2 $FONT_WIDTH
}

# get_num_chars wrapper for 20-pt monospaced font
get_num_chars_20_mono() {
    FONT_WIDTH=6.62
    get_num_chars $1 $2 $FONT_WIDTH
}

# get_num_chars wrapper for 18-pt monospaced font
get_num_chars_18_mono() {
    FONT_WIDTH=5.75
    get_num_chars $1 $2 $FONT_WIDTH
}
