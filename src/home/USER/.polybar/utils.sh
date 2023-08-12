#!/bin/bash


# Given a randr display identifier, a fraction, and a monospace font 
# width (pts), return the number of characters (floored to the first integer) 
# that can fit within the fraction of one row of the display 
get_num_chars() {
    DISPLAY_ID=$1
    DISPLAY_FRACTION=$2
    FONT_WIDTH=$3  # measured in characters per pixel

    display_header=$(xrandr | grep $DISPLAY_ID)    
    display_pixel_width=$(xrandr | grep DP-2 | cut -d 'x' -f1 | tr ' ' '\n' | tail -n 1)

    # convert width to pts, scale by fraction, and convert to num of chars;
    # 1 in / 24.5 mm, 72 pts / in, 1 char / FONT_WIDTH pts
    num_chars=$(bc -l <<< "${FONT_WIDTH} * ${display_pixel_width} * ${DISPLAY_FRACTION}")  

    # return num_chars floored to integer
    echo $(bc <<< "scale=0; ${num_chars} / 1")
}

# get_num_chars wrapper for 26-pt monospaced font
get_num_chars_26_mono() {
    FONT_WIDTH=0.053
    get_num_chars $1 $2 $FONT_WIDTH
}

# get_num_chars wrapper for 20-pt monospaced font
get_num_chars_20_mono() {
    FONT_WIDTH=0.067
    get_num_chars $1 $2 $FONT_WIDTH
}
