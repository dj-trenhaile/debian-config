#!/bin/bash

if [ "$(powerprofilesctl get)" == "power-saver" ]
then   
    picom --config $HOME/.config/picom/config --backend xr_glx_hybrid --no-use-damage &
    powerprofilesctl set balanced
    polybar-msg hook ecomode 2
else   
    pkill -9 picom
    powerprofilesctl set power-saver
    polybar-msg hook ecomode 3
fi