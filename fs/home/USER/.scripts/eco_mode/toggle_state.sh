#!/bin/bash

if [ "$(powerprofilesctl get)" == "performance" ]
then   
    pkill -9 picom
    powerprofilesctl set power-saver
    polybar-msg hook ecomode 3
else   
    picom --config $HOME/.config/picom/config --backend xr_glx_hybrid --no-use-damage &
    powerprofilesctl set performance
    polybar-msg hook ecomode 2
fi