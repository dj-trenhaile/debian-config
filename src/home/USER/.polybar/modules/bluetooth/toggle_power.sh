#!/bin/bash

if [ "$(rfkill list bluetooth | grep 'Soft blocked: no')" == '' ]; then
    rfkill unblock bluetooth
else
    if [ "$(bluetoothctl show | grep 'Powered: yes')" == '' ]; then
        bluetoothctl power on
    else
        bluetoothctl power off
    fi
fi
