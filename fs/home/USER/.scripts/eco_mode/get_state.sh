#!/bin/bash

# loading
echo "initializing..."

if [ "$(powerprofilesctl get)" == "performance" ]
then
    polybar-msg hook ecomode 2 &> /dev/null
else
    pkill -9 picom  # in case latent process exists; throws error on toggle if not killed here
    polybar-msg hook ecomode 3 &> /dev/null
fi
    

