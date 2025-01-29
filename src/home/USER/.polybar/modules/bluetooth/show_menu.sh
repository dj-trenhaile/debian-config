#!/bin/bash

if [ "$(rfkill list bluetooth | grep 'Soft blocked: no')" == '' ]; then
    rfkill unblock bluetooth
elif [ "$(bluetoothctl show | grep 'Powered: yes')" == '' ]; then
    bluetoothctl power on
fi

blueman-manager
