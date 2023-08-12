#!/bin/bash

power-saver() {
    ~/.i3/power_profiles/power-saver.sh
    polybar-msg hook ecomode 3 &> /dev/null
}

balanced() {
    ~/.i3/power_profiles/balanced.sh
    flock -u 9  # open file descriptor passed on to picom instance; unlock explicitly
    polybar-msg hook ecomode 2 &> /dev/null
}
