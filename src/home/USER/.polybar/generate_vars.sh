#!/bin/bash

vars=""
# get variables ============================================================== #
# BAR_TEMPERATURE_ZONE
ZONE=0
for zone in /sys/class/thermal/thermal_zone*
do
    if [ "$(cat ${zone}/type)" == "x86_pkg_temp" ]
    then
        ZONE="${zone: -1}"
    fi
done
vars="${vars}BAR_TEMPERATURE_ZONE=${ZONE}\n"


# write labels and variables ================================================= #
cat $HOME/.config/polybar/labels.txt > $POLYBAR_VARS
echo -e "\n\n${vars}" >> $POLYBAR_VARS
