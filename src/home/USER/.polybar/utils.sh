#!/bin/bash

# Given a randr display identifier, a fraction, and a monospace font width (pts), print the number 
# of chars (floored to the first integer) that can fit in the fraction of one row of the display 
# 
# $1 - display randr ID of which to find fractional char capacity
# $2 - display fraction of which to find char capacity
# $3 - monospace char width (pts) of which to find fractional capacity 
get_num_chars() {
    DISPLAY_ID=$1
    DISPLAY_FRACTION=$2
    FONT_WIDTH=$3

    display_pixel_width=$(xrandr | grep $DISPLAY_ID | cut -d x -f1 | tr ' ' "\n" | tail -n 1)
    num_chars=$(bc <<< "$FONT_WIDTH * $display_pixel_width * $DISPLAY_FRACTION")  

    echo $(bc <<< "scale=0; $num_chars / 1")
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
