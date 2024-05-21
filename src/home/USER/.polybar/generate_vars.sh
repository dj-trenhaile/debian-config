#!/bin/bash

vars=''


# get variables ============================================================== #

# BAR_TEMPERATURE_ZONE
ZONE=0
for zone in /sys/class/thermal/thermal_zone*; do
    if [ "$(cat $zone/type)" == 'x86_pkg_temp' ]; then
        ZONE=${zone: -1}
    fi
done
vars="${vars}BAR_TEMPERATURE_ZONE=${ZONE}\n"

# BAR_BACKLIGHT_CARD
CARD=$(ls -1 /sys/class/backlight | head -n 1)
vars="${vars}BAR_BACKLIGHT_CARD=${CARD}\n"

# BAR_BATTERY
BAT=$(ls /sys/class/power_supply | grep BAT | head -n 1)
vars="${vars}BAR_BATTERY=${BAT}\n"

# BAR_BATTERY_ADAPTER
ADP=$(ls /sys/class/power_supply | grep ^A | head -n 1)
vars="${vars}BAR_BATTERY_ADAPTER=${ADP}\n"

# ======================== #


# write labels and variables ================================================= #
cat $HOME/.config/polybar/labels.txt > $_POLYBAR_VARS
echo -e "\n\n${vars}" >> $_POLYBAR_VARS
# ======================== #

