#!/bin/bash

if [ "$(pgrep -f systemsettings)" == '' ]; then
    echo  
else 
    echo  
fi

systemctl --user restart polybar-module_settings.service &> /dev/null
