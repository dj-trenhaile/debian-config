#!/bin/bash

if [ "$(bluetoothctl show | grep 'Powered: yes')" == '' ]; then
    bluetoothctl power on
else
    bluetoothctl power off
fi
