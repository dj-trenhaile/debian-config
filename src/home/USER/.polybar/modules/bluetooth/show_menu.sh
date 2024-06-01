#!/bin/bash

if [ "$(bluetoothctl show | grep 'Powered: yes')" == '' ]; then
    bluetoothctl power on
fi
blueman-manager
