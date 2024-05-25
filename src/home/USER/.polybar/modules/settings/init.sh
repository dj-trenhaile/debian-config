#!/bin/bash

if [ "$(pgrep -f systemsettings)" == '' ]; then
    echo  
else 
    echo  
fi
systemctl --user start polybar-module_settings.service &> /dev/null

