#!/bin/bash

_DIR="${BASH_SOURCE%/*}"
DRY=0
OVERWRITE=0
REFRESH_ONLY=0


# check that user is not root
user=$(whoami)
if [ "$user" == "root" ]
then
    echo "Install should be performed on a non-root user. Aborting..."
    exit 1
fi


# parse args ================================================================= #
help() {
    echo -e "Usage: install.sh [OPTION]...
    -d, --dry               perform a dry run; do not modify any files, systemd services, or packages
    -o, --overwrite         do not save existing files, immediately overwrite them
    -r, --refresh-only      do not modify systemd services or packages, only refresh files from src
    -h, --help              display this help and exit"
}

if ! args=$(getopt -o d,o,r,h -l dry,overwrite,refresh-only,help -- "$@")
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
        -r | --refresh-only)
            REFRESH_ONLY=1
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

# confirm installation user
echo "Please confirm your user before proceeding: ${user} [Y/n]"
read -p "" user_confirmation
if [ "$user_confirmation" != "Y" ]
then
    echo "Aborting..."
    exit 1
fi


# modify systemd services and packages ======================================= #
# enable remote login
sudo apt install openssh-server
sudo systemctl enable ssh 

# install DE, configure associated systemd services
sudo apt install kde-standard
systemctl --user mask plasma-kwin_x11.service
systemctl --user add-wants plasma-workspace-x11.target plasma-i3_x11.service
systemctl --user mask plasma-plasmashell.service

# install essential software
sudo apt install pulseaudio \
                 playerctl \
                 cava \
                 brightnessctl \
                 net-tools

# install other software
sudo apt install google-chrome-stable \
                 code
sudo snap install spotify \
                  slack \
                  orange-app 





# file modification helpers ================================================== #
traverse() {
    for entry in $(ls -A $1 | grep -v "dbus-1")
    do
        path="${1}${entry}"
        if [ -f $path ]
        then   
            DIR=$1
            file="/${path}"
            if [ -f $file ]
            then
                refresh_file overwrite_file
            else
                refresh_file install_file
            fi
        else
            traverse "${path}/"
        fi
    done
}


refresh_file() {
    CALLBACK=$1
    
    echo "    ${path}"
    if [ $DRY -eq 0 ]
    then
        $CALLBACK
    fi
}


overwrite_file() {
    if [ $OVERWRITE -eq 0 ]
    then
        echo -n "        save: "   
        {
            save="/${DIR}.${entry#.}.$$.bak"
            # mv $file $save
            saves=$((saves+1))
            echo $save
            
            install_file
        } || handle_failure
    fi
}


install_file() {
    echo -n "        install: "
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



# initialize stats
installs=0
saves=0
dbus_mods=0
systemd_mods=0
failures=0
# move to source dir
cd "${_DIR}/src"


# root files ================================================================= #
echo "Installing root files..."
for dir in $(ls -d */ | grep -v "home")
do
    traverse "$dir"
done


# user files ================================================================= #
echo "Installing user files..."



# dbus services ============================================================== #
echo "Modifying DBus services..."
services="usr/share/dbus-1/services/"
for service in $(ls $services | grep "disabled")
do
    path="${services}${service}"
    if [ -f $path ]
    then
        file="/${services}${service%.disabled}"
        if [ -f $file ]
        then
            echo "    ${path}"
            if [ $DRY -eq 0 ]
            then
                echo -n "        disable: "
                {
                    file_disabled="/${path}"
                    # mv $file $file_disabled
                    dbus_mods=$((dbus_mods+1))
                    echo $file_disabled
                } || handle_failure
            fi       
        fi
    else
        echo "not a file"
    fi
done


# systemd services =========================================================== #



# display final stats
echo
echo -e "Done.
Files installed: ${installs}
Existing files saved: ${saves}
DBus services modified: ${dbus_mods}
Systemd services modified: ${systemd_mods}
Failures: ${failures}"
