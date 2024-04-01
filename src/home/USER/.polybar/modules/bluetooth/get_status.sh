#!/bin/sh

if [ $(bluetoothctl show | grep "Powered: yes" | wc -c) -eq 0 ]; then
  echo "%{F$COLOR_DISABLED}%{F-}"
else
  if [ $(bluetoothctl info | grep "DeviceSet (null)" | wc -c) -eq 0 ]; then
    echo "%{F#2193ff}%{F-}"
  else
    echo ""
  fi
fi