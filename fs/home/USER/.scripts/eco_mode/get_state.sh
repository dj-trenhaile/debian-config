#!/bin/bash

if [ "$(powerprofilesctl get)" == "performance" ]
then
    polybar-msg hook ecomode 2
else
    pkill -9 picom  # in case latent process exists; throws error on toggle if not killed here
    polybar-msg hook ecomode 3
fi
    

