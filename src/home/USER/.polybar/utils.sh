#!/bin/bash

# Given a randr display identifier, a fraction, and a monospace font 
# width (pts), return the number of characters (floored to the first integer) 
# that can fit within the fraction of one row of the display 
get_num_chars() {
    DISPLAY_ID=$1
    DISPLAY_FRACTION=$2
    FONT_WIDTH=$3  # measured in characters per pixel

    display_pixel_width=$(xrandr | grep $DISPLAY_ID | cut -d x -f1 | tr ' ' "\n" | tail -n 1)
    num_chars=$(bc <<< "$FONT_WIDTH * $display_pixel_width * $DISPLAY_FRACTION")  

    # return num_chars floored to integer
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

