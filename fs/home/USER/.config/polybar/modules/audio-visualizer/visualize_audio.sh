#!/bin/bash

bar="▁▂▃▄▅▆▇█"
dict="s/;//g;"

# creating "dictionary" to replace char with bar
i=0
while [ $i -lt ${#bar} ]
do
    dict="${dict}s/$i/${bar:$i:1}/g;"
    i=$((i=i+1))
done

# make sure to clean pipe
pipe="/tmp/cava.fifo"
if [ -p $pipe ]; then
    unlink $pipe
fi
mkfifo $pipe

# write cava config
config="/tmp/cava_config"
echo "

[general]
bars = 100

[output]
method = raw
raw_target = $pipe
data_format = ascii
ascii_max_range = 7

" > $config

# run cava
pkill cava  # kill any lingering instances
cava -p $config &
# if pulseaudio sinks change, signal cava to reload so that it
# grabs the new default
~/.config/polybar/modules/audio-visualizer/watch_pa.sh &

# reading data from fifo
while read -r cmd; do
    echo $cmd | sed $dict
done < $pipe
