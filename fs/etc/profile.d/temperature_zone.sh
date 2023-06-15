ZONE=0

for zone in /sys/class/thermal/thermal_zone*
do
    if [ "$(cat ${zone}/type)" == "x86_pkg_temp" ]
    then
        ZONE="${zone: -1}"
    fi
done

export BAR_TEMPERATURE_ZONE=$ZONE

