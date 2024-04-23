#!/bin/bash
_REL_PATH=${BASH_SOURCE%/*}
_ORIGIN_DIR=$(pwd)
source ${_REL_PATH}/build/utils.sh
DRY=0
OVERWRITE=0
REFRESH_ONLY=0


# check that user is not root
if [ "$USER" == "root" ]; then
    echo Install should be performed on a non-root user. Abort.
    exit 1
fi


# parse args ================================================================= #

help() {
    echo -e "Usage: install.sh [OPTION]...
    -d, --dry              do not modify any src files, install any packages, or perform systemd integration; show src files that would be installed
    -r, --refresh          do not install any packages or perform systemd integration; install src files
    -o, --overwrite        do not back up existing files, immediately overwrite them
    -h, --help             display this help and exit"
}

if ! args=$(getopt -o d,r,o,h -l dry,refresh,overwrite,help -- $@); then
    help
    exit 1
fi

eval set -- $args
for arg in $@; do
    case $arg in 
        -d | --dry)
            DRY=1
            ;;
        -r | --refresh)
            REFRESH_ONLY=1
            ;;
        -o | --overwrite)
            OVERWRITE=1
            ;;
        -h | --help)
            help
            exit 0
            ;;
        --)
            ;;
    esac  
    shift  
done


if [ $DRY -eq 1 ]; then
    echo ***Performing dry run.
fi

# confirm installation user
echo Please confirm your user before proceeding: $USER [Y/n]
read -p "" user_confirmation
if [ "$user_confirmation" != "Y" ]; then
    echo Abort.
    exit 1
fi


# packages and systemd integration =========================================== #
if [ $REFRESH_ONLY -eq 0 ] && [ $DRY -eq 0 ]; then
    echo Installing packages and performing systemd integration...
    cd ~/Downloads

    # enable remote login
    sudo apt install openssh-server
    sudo systemctl enable ssh 

    # install DE, configure associated systemd services
    sudo apt install kde-standard
    sudo apt remove qt5ct && sudo apt autoremove  # evil; see https://forum.manjaro.org/t/plasma-application-appearance-and-styles-not-changing/83955/2
    systemctl --user mask plasma-kwin_x11.service
    systemctl --user add-wants plasma-workspace-x11.target plasma-i3_x11.service
    systemctl --user mask plasma-plasmashell.service

    # install window management and appearance software
    sudo apt install i3 \
                     polybar \
                     rofi \
                     picom \
                     nitrogen \
                     libinput-tools \
                     blueman \
                     lxappearance
    # settings
    dconf write /org/blueman/general/plugin-list "['\!ConnectionNotifier', '\!AutoConnect']"

    # install script dependencies
    sudo apt install pulseaudio \
                     playerctl \
                     cava \
                     net-tools
    # TODO: integrate brightnessctl elsewhere

    # install font(s)
    sudo apt install fonts-3270
    fonts=$(fc-list)
    if [ "$(echo $fonts | grep 3270NerdFontMono-Regular.ttf)" == "" ]; then
        wget https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/3270/Regular/3270NerdFontMono-Regular.ttf
        sudo mv 3270NerdFontMono-Regular.ttf /usr/share/fonts/truetype/3270/
    fi
    if [ "$(echo $fonts | grep SymbolsNerdFont-Regular.ttf)" == "" ]; then
        wget https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/NerdFontsSymbolsOnly/SymbolsNerdFont-Regular.ttf
        sudo mkdir /usr/share/fonts/truetype/symbols-nerdfont 2> /dev/null
        sudo mv SymbolsNerdFont-Regular.ttf /usr/share/fonts/truetype/symbols-nerdfont/
    fi
    if [ "$(echo $fonts | grep JetBrainsMono-Regular.ttf)" == "" ]; then
        wget https://github.com/JetBrains/JetBrainsMono/raw/master/fonts/ttf/JetBrainsMono-Regular.ttf
        sudo mkdir /usr/share/fonts/truetype/jetbrainsmono 2> /dev/null
        sudo mv JetBrainsMono-Regular.ttf /usr/share/fonts/truetype/jetbrainsmono/
    fi
    fc-cache -vf /usr/share/fonts

    # install other software
    sudo apt install google-chrome-stable \
                     xdotool \
                     xclip \
                     ffmpeg \
                     font-manager \
                     gparted \
                     audacity \
                     kid3
    snaps=(spotify slack)
    for candidate in ${snaps[@]}; do
        sudo snap install $candidate
    done
    vscode_extensions=(ms-vscode.cpptools
                       ms-vscode.cpptools-themes
                       eamodio.gitlens
                       mhutchie.git-graph
                       ms-vscode.live-server 
                       webfreak.debug
                       chrisdias.vscode-opennewinstance
                       ms-python.python
                       ms-python.vscode-pylance
                       ms-python.debugpy
                       dlasagno.rasi
                       lihui.vs-color-picker
                       13xforever.language-x86-64-assembly)
    for extension in ${vscode_extensions[@]}; do
        code --install-extension $extension
    done

    # install and configure anaconda
    if [ "$(which conda)" == "" ]; then
        wget https://github.com/conda-forge/miniforge/releases/latest/download/Mambaforge-$(uname)-$(uname -m).sh
        bash Mambaforge-$(uname)-$(uname -m).sh
        conda config --set env_name "({name})"
    fi

    cd ${_ORIGIN_DIR}/${_REL_PATH}
    echo "    ---- done."
fi


init_stats
cd $_REL_PATH



# root files ================================================================= #

echo Installing root files...
FILE_PREFIX=src
USER_PATH=${FILE_PREFIX}/home/USER/
DBUS_SERVICES_PATH=${FILE_PREFIX}/usr/share/dbus-1/services/
for file_path in $(find $FILE_PREFIX -type f ! -path ${USER_PATH}* \
                                             ! -path ${DBUS_SERVICES_PATH}*); do
    local_file_path=${file_path#$FILE_PREFIX}
    if [ -f $local_file_path ]; then
        if [ "$(cat $local_file_path)" != "$(cat $file_path)" ]; then
            print_file_path
            [ $DRY -eq 1 ] && continue
            log=$(sudo OVERWRITE=$OVERWRITE \
                       file_path=$file_path \
                       local_file_path=$local_file_path \
                       ./build/util_wrapper.sh replace_file)
            parse_log
        fi
    else
        print_file_path
        [ $DRY -eq 1 ] && continue
        log=$(sudo local_file_path=$local_file_path \
                   ./build/util_wrapper.sh make_dirs)
        parse_log
        log=$(sudo file_path=$file_path \
                   local_file_path=$local_file_path \
                   ./build/util_wrapper.sh install_file)
        parse_log
    fi 
done

echo "    -------- dbus services..."
for file_path in $(find $DBUS_SERVICES_PATH | grep disabled); do
    local_service_disabled=${file_path#$FILE_PREFIX}
    local_service=${local_service_disabled%.disabled}
    if [ -f $local_service ]; then
        print_file_path
        [ $DRY -eq 1 ] && continue
        log=$(sudo local_service=$local_service \
                   local_service_disabled=$local_service_disabled \
                   ./build/util_wrapper.sh "disable_service")
        parse_log
    fi
done

echo "    ---- done."



# user files ================================================================= #

echo "Installing user files..."
LOCAL_USER_PATH=/home/${USER}/
for dir in $(find $USER_PATH -maxdepth 1 -type d ! -path $USER_PATH); do
    for file_path in $(find $dir -type f ); do
        local_file_path=${LOCAL_USER_PATH}${file_path#$USER_PATH}
        if [ -f $local_file_path ]; then
            if [ "$(cat $local_file_path)" != "$(cat $file_path)" ]; then
                print_file_path
                [ $DRY -eq 1 ] && continue
                replace_file
            fi
        else
            print_file_path
            [ $DRY -eq 1 ] && continue
            make_dirs
            install_file
        fi 
    done
done


write_dotfile_content() {
    sed -i$backup_suffix "${header_line} a \\\\" $local_file_path
    sed -i "${header_line} r $file_path" $local_file_path
    installs=$((installs+1))
}

echo "    -------- top-level dotfile insertions..."
HEADER="# >>> DE install >>>"
FOOTER="# <<< DE install <<<"
for file_path in $(find $USER_PATH -maxdepth 1 -type f); do
    local_file_path=${LOCAL_USER_PATH}${file_path#$USER_PATH}
    local_file_lines_cnt=0
    
    backup_suffix=""
    if [ $OVERWRITE -eq 1 ]; then
        backup_suffix=$$.bak
    fi

    if [ -f $local_file_path ]; then
        local_file_lines_cnt=$(cat $local_file_path | wc -l)
        header_line=$(grep -n "$HEADER" $local_file_path | head -n 1 | cut -d ':' -f1)
        if [ "$header_line" != "" ]; then
            footer_line=$(grep -n "$FOOTER" <<< $(cat $local_file_path | tail -n $((local_file_lines_cnt - header_line))) | tail -n 1 | cut -d ':' -f1)
            if [ "$footer_line" != "" ]; then
                # footer_line cooresponds to line of FOOTER in previously
                # defined "here" doc; offset it by header_line so that it
                # cooresponds to the same in the local file
                footer_line=$((footer_line + header_line))

                content_start_line=$((header_line + 1))
                content_end_line=$((footer_line - 1))

                if [ $content_end_line -ge $content_start_line ]; then
                    # content region is at least 1 line long; if out of date,
                    # replace it 
                    if [ "$(sed -n ${content_start_line},${content_end_line}p $local_file_path)" != "$(cat $file_path)" ]; then
                        print_file_path
                        [ $DRY -eq 1 ] && continue
                        sed -i$backup_suffix ${content_start_line},${content_end_line}d $local_file_path
                        backup_suffix=""
                        write_dotfile_content
                    fi
                else
                    # content region is 0 lines long; perform insert
                    print_file_path
                    [ $DRY -eq 1 ] && continue
                    write_dotfile_content
                fi

                # proceed to next dotfile
                continue     
            fi
        fi
    else
        touch $local_file_path
    fi

    # dotfile has no valid install section; append changes to EOF
    print_file_path
    [ $DRY -eq 1 ] && continue
    header_line=$((local_file_lines_cnt + 1))
    footer_line=$((local_file_lines_cnt + 2))
    echo -e "${HEADER}\n${FOOTER}" >> $local_file_path
    write_dotfile_content 
done


echo "    -------- resources..."
RESOURCE_PREFIX=res
LOCAL_RESOURCES_DIR="${LOCAL_USER_PATH}.resources"
mkdir -p $LOCAL_RESOURCES_DIR
for file_path in $(find $RESOURCE_PREFIX -type f); do
    local_file_path=$LOCAL_RESOURCES_DIR${file_path#$RESOURCE_PREFIX}
    if [ ! -f $local_file_path ]; then
        print_file_path
        [ $DRY -eq 1 ] && continue
        install_file
    fi
done
    

echo "    ---- done."



# display final stats
echo
echo -e "Done.
src files installed: $installs
Local files backed up: $backups
Failures: $failures"
