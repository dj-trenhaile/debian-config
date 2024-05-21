#!/bin/bash

if [ "$(bluetoothctl show | grep 'Powered: yes')" == '' ]; then
  echo "%{F$COLOR_DISABLED}%{F-}"
else
  if [ "$(bluetoothctl info | grep 'DeviceSet (null)')" == '' ]; then
    echo '%{F#2193ff}%{F-}'
  else
    echo 
  fi
fi

