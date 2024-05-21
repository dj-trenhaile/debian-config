#!/bin/bash

# set variables
set -a
source $_POLYBAR_VARS
set +a
export BAR_MONITOR=$(get-current-display)
echo "monitor: $BAR_MONITOR"

# launch bar
polybar extras-secondary &

