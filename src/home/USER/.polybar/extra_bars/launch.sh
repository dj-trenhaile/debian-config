#!/bin/bash

# set variables
set -a
source "$_POLYBAR_VARS"
BAR_MONITOR=$(get-current-display)
set +a

# launch bar
polybar extras-secondary &
