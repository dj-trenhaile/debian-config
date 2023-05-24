#!/bin/bash

if [ "$(powerprofilesctl get)" == "power-saver" ]
then
    pkill -9 picom  # in case latent process exists; throws error on toggle if not killed here
    polybar-msg hook ecomode 3 &> /dev/null
else
    polybar-msg hook ecomode 2 &> /dev/null
fi
    

