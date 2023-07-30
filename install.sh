#!/bin/bash

_DIR="${BASH_SOURCE%/*}"
DRY=0
OVERWRITE=0


# parse args ================================================================= #
help() {
    echo -e "Usage: install.sh [OPTION]...
    -d, --dry             perform a dry run; do not modify any files
    -o, --overwrite       do not save existing files, immediately overwrite them
    -h, --help            display this help and exit"
}

if ! args=$(getopt -o d,o,h -l dry,overwrite,help -- "$@")
then
    help
    exit 1
fi

eval set -- $args
for arg in $@
do  
    case $arg in 
        -d | --dry)
            DRY=1
            shift
            ;;
        -o | --overwrite)
            OVERWRITE=1
            shift
            ;;
        -h | --help)
            help
            exit 0
            ;;
        --)
            shift
            ;;
    esac    
done


if [ $DRY -eq 1 ]
then
    echo "***Performing dry run."
fi

echo "Please confirm your user before proceeding: $(whoami) [Y/n]"
read -p "" user_confirmation
if [ "$user_confirmation" != "Y" ]
then
    echo "Aborting..."
    exit 1
fi


traverse() {
    for entry in $(ls -A $1 | grep -v "dbus-1")
    do
        path="${1}${entry}"
        if [ -f "$path" ]
        then   
            echo "    ${path}"
            if [ $DRY -eq 0 ]
            then 
                file="/${path}"
                if [ $OVERWRITE -eq 0 ] && [ -f $file ]
                then
                    echo -n "        saved: "   
                    {
                        save="/${1}.${entry#.}.$$.bak"
                        # mv $file $save
                        saves=$((saves+1))
                        echo $save
                        
                        copy_file
                    } || handle_failure
                else
                    copy_file
                fi                             
            fi
            # TODO: if an overwrite occurs, save original file at location 
        else
            traverse "${path}/"
        fi
    done
}


copy_file() {
    echo -n "        modified: "
    {
        # cp $path $file
        installs=$((installs+1))
        echo $file
    } || handle_failure
}


handle_failure() {
    echo "FAILED"
    failures=$((failures+1))
}


installs=0
saves=0
dbus_mods=0
systemd_mods=0
failures=0
cd "${_DIR}/src"

echo "Copying root files..."
for dir in $(ls -d */ | grep -v "home")
do
    traverse "$dir"
done

echo "Modifying DBus services..."
# for service in $(ls )


echo
echo -e "Done.
Files installed: ${installs}
Existing files saved: ${saves}
DBus services modified: ${dbus_mods}
Systemd services modified: ${systemd_mods}
Failures: ${failures}"

exit 0

echo "Copying user files..."
















# then do user-owned files in home/USER 

whoami


# 
# traverse "."






