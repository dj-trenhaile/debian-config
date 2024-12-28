#!/bin/bash
 _REL_PATH=${BASH_SOURCE%/*}

source "$_REL_PATH/build/utils.sh"

DRY=0
OVERWRITE=0
REFRESH_ONLY=0


# check that user isn't root
if [ "$USER" == 'root' ]; then
    echo Install should be performed on a non-root user. Abort.
    exit 1
fi


# parse args ================================================================= #

help() {
    echo "Usage: install.sh [OPTION]...
    -d, --dry              don't install any files nor perform system integration; show src files that would be installed
    -r, --refresh          don't perform system integration; install src files
    -o, --overwrite        don't back up existing files, immediately overwrite them
    -h, --help             display this help and exit"
}

# validate conformance of command line args
if ! getopt -o d,r,o,h -l dry,refresh,overwrite,help -- $@ > /dev/null; then
    help
    exit 1
fi

i=1
while [ $i -le $# ]; do
    case ${!i} in
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
    esac
    ((i++))
done

# ========================= # 


if [ $DRY -eq 1 ]; then
    echo ***Performing dry run.
fi

# confirm installation user
read -p "Please confirm your user before proceeding: $USER [Y/n] " user_confirmation
if [ "$user_confirmation" != 'Y' ]; then
    echo Abort.
    exit 1
fi


# system integration ========================================================= #
if [ $REFRESH_ONLY -eq 0 ] && [ $DRY -eq 0 ]; then
    echo Performing system integration...

    cwd=$(pwd)
    cd ~/Downloads

    # enable remote login
    sudo apt install openssh-server
    sudo systemctl enable ssh 

    # install DE, configure associated systemd services
    sudo apt install kde-standard
    sudo apt remove qt5ct && sudo apt autoremove  # evil; see https://forum.manjaro.org/t/plasma-application-appearance-and-styles-not-changing/83955/2
    systemctl --user mask plasma-kwin_x11.service
    systemctl --user mask plasma-plasmashell.service

    # install core window management and appearance packages
    sudo apt install i3 \
                     polybar \
                     picom \
                     nitrogen
                    
    
    # manage other script dependencies
    
    sudo apt install pulseaudio \
                     playerctl \
                     brightnessctl \
                     ffmpeg \
                     blueman \
                     cava \
                     gnome-screenshot \
                     net-tools \
                     xdotool \
                     tree
    
    sudo usermod -a -G video "$USER"
    
    dconf write /org/blueman/general/plugin-list "['\!ConnectionNotifier', '\!AutoConnect']"
    sudo apt remove bluedevil

    dconf write /org/gnome/gnome-screenshot/auto-save-directory "'/home/$USER/Pictures/Screenshots'"


    # install font(s)
    
    sudo apt install fonts-3270

    fonts_dir='/usr/share/fonts'

    fonts=$(fc-list)
    fonts_truetype_dir="$fonts_dir/truetype"
    install_font() {
        # url of the font to download
        URL=$1
        # dir in $fonts_truetype_dir in which to install the font
        DEST_DIR=$2

        installed=0
        
        file=${URL##*/}
        if [ "$(echo $fonts | grep "$file")" == '' ]; then
            
            wget "$URL"
            dest_dir_path=$fonts_truetype_dir/$DEST_DIR 
            sudo mkdir "$dest_dir_path" 2> /dev/null
            sudo mv "$file" "$dest_dir_path" 

            installed=1 
        fi

        echo $installed
    }

    if [ "$(install_font 'https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/3270/Regular/3270NerdFontMono-Regular.ttf' \
                         '3270')" -eq 1 ] ||
       [ "$(install_font 'https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/NerdFontsSymbolsOnly/SymbolsNerdFont-Regular.ttf' \
                         'symbols-nerdfont')" -eq 1 ] ||
       [ "$(install_font 'https://github.com/JetBrains/JetBrainsMono/raw/master/fonts/ttf/JetBrainsMono-Regular.ttf' \
                         'jetbrainsmono')" -eq 1 ]; then
       fc-cache -v $fonts_dir
    fi


    # remove select packages
    sudo snap remove snapd-desktop-integration


    # ========================= #
    # optional software
    # ========================= #

    sudo apt install asdf



    sudo apt install xclip \
                     curl \
                     ploate



    sudo apt install libinput-tools \
                     gparted \
                     gcc \
                     font-manager \
                     audacity \
                     kid3

    snaps=(spotify slack)     
    for snap in ${snaps[@]}; do
        sudo snap install "$snap"
    done
    extensions=(eamodio.gitlens
                mhutchie.git-graph
                chrisdias.vscode-opennewinstance
                ms-vscode.live-server
                13xforever.language-x86-64-assembly
                ms-vscode.cpptools
                ms-vscode.cpptools-themes
                webfreak.debug
                rogalmic.bash-debug
                ms-python.python
                ms-python.vscode-pylance
                ms-python.debugpy
                ms-toolsai.jupyter
                lihui.vs-color-picker
                mechatroner.rainbow-csv
                James-Yu.latex-workshop)





    for extension in ${extensions[@]}; do
        code --install-extension "$extension"
    done

    # anaconda
    if [ "$(which conda)" == '' ]; then
        
        file=Miniforge3-$(uname)-$(uname -m).sh
        wget https://github.com/conda-forge/miniforge/releases/latest/download/$file
        chmod +x $file
        bash $file
        conda config --set env_prompt '({name})'
    fi
    

    cd "$cwd"
    echo '    ---- done.'

fi
# ========================= # 


init_stats
cd "$_REL_PATH"


# root files ================================================================= #

echo Installing root files...
# iterate src files, ignore user home and dbus services paths
FILE_PREFIX=src
USER_PATH=$FILE_PREFIX/home/USER/
DBUS_SERVICES_PATH=$FILE_PREFIX/usr/share/dbus-1/services/
for file_path in $(find "$FILE_PREFIX" -type f ! -path "$USER_PATH*" \
                                               ! -path "$DBUS_SERVICES_PATH*"); do
    
    # define cooresponding local file path
    local_file_path=${file_path#$FILE_PREFIX}
    
    if [ -f "$local_file_path" ]; then
        # local file exists; if local contents dissimilar, proceed
        if [ "$(cat "$local_file_path")" != "$(cat "$file_path")" ]; then

            print_file_path
            [ $DRY -eq 1 ] && continue

            # replace local file
            log=$(sudo OVERWRITE="$OVERWRITE" \
                       file_path="$file_path" \
                       local_file_path="$local_file_path" \
                       ./build/util_wrapper.sh replace_file)
            parse_log
        fi
        
    else
        # local file doesn't exist

        print_file_path
        [ $DRY -eq 1 ] && continue

        # create intermediate dir(s)
        log=$(sudo local_file_path="$local_file_path" \
                   ./build/util_wrapper.sh make_dirs)
        parse_log
        
        # install local file
        log=$(sudo file_path="$file_path" \
                   local_file_path="$local_file_path" \
                   ./build/util_wrapper.sh install_file)
        parse_log
    fi 
done
systemctl --user add-wants plasma-workspace-x11.target plasma-i3_x11.service

echo '    -------- dbus services...'
# iterate src dbus service files
for file_path in $(find "$DBUS_SERVICES_PATH" | grep disabled); do
    
    # define cooresponding local disabled file path
    local_service_disabled=${file_path#$FILE_PREFIX}
    # define cooresponding local active file path
    local_service=${local_service_disabled%.disabled}

    # if local active file exists, proceed
    if [ -f "$local_service" ]; then
        
        print_file_path
        [ $DRY -eq 1 ] && continue
        
        # disable local file
        log=$(sudo local_service="$local_service" \
                   local_service_disabled="$local_service_disabled" \
                   ./build/util_wrapper.sh disable_service)
        parse_log
    fi
done

echo '    ---- done.'

# ========================= # 


# user files ================================================================= #

echo Installing user files...
# iterate src user home dirs
LOCAL_USER_PATH=/home/$USER/
for dir in $(find "$USER_PATH" -maxdepth 1 -type d ! -path "$USER_PATH"); do
    
    # iterate dir files
    for file_path in $(find "$dir" -type f ); do
        
        # define cooresponding local file path
        local_file_path=$LOCAL_USER_PATH${file_path#$USER_PATH}
        
        if [ -f "$local_file_path" ]; then
            # local file exists; if contents dissimilar, replace it 
            if [ "$(cat "$local_file_path")" != "$(cat "$file_path")" ]; then
                print_file_path
                [ $DRY -eq 1 ] && continue
                replace_file
            fi

        else
            # local file doesn't exist

            print_file_path
            [ $DRY -eq 1 ] && continue
            
            make_dirs
            install_file
        fi 
    done
done

echo '    -------- top-level dotfile insertions...'
HEADER='# >>> DE install >>>'
FOOTER='# <<< DE install <<<'
# iterate src user home files
for file_path in $(find "$USER_PATH" -maxdepth 1 -type f); do
    
    # define cooresponding local file path
    local_file_path=$LOCAL_USER_PATH${file_path#$USER_PATH}

    if [ -f "$local_file_path" ]; then
        # local file exists

        local_file_lines_cnt=$(cat "$local_file_path" | wc -l)

        # init: append new write section 2 lines below last line
        setup_cmd="$local_file_lines_cnt a \\\n$HEADER\n$FOOTER"
        append_line_num=$((local_file_lines_cnt + 2))


        # ========================= #
        # check current file state; get new setup cmd and append line num if
        # necessary, or continue to next file if local file up-to-date
        # ========================= #

        # search for line num of existing header
        header_line_num=$(grep -n "$HEADER" "$local_file_path" | head -n 1 | cut -d : -f1)
        if [ "$header_line_num" != '' ]; then
            # header exists; set append line num
            append_line_num=$header_line_num

            # if lines after header, proceed
            if [ $header_line_num -lt $local_file_lines_cnt ]; then

                content_start_line_num=$((header_line_num + 1))

                # search for offset from header to existing footer
                footer_offset=$(grep -n "$FOOTER" <<< $(
                                    cat "$local_file_path" | 
                                    tail -n $((local_file_lines_cnt - header_line_num))
                                ) | tail -n 1 | cut -d : -f1)
                if [ "$footer_offset" != '' ]; then

                    # if content region gt 0 lines, proceed
                    content_end_line_num=$((header_line_num + footer_offset - 1))
                    if [ $content_end_line_num -ge $content_start_line_num ]; then

                        if [ "$(sed -n "$content_start_line_num,$content_end_line_num p" "$local_file_path")" == \
                             "$(cat "$file_path")" ]; then
                            # local file matches src file; continue to next src file
                            continue

                        else
                            # local file doesn't match src file; set setup_cmd to delete all lines 
                            # between header and footer
                            setup_cmd="$content_start_line_num,$content_end_line_num d"
                        fi
                    fi
                else
                    # no footer after header; set setup_cmd to replace all  
                    # lines after header w/ just footer
                    setup_cmd="$content_start_line_num,$local_file_lines_cnt c $FOOTER"
                fi
            else
                # no lines after header; set setup_cmd to append a footer
                setup_cmd="$header_line_num a $FOOTER" 
            fi
        fi

        print_file_path
        [ $DRY -eq 1 ] && continue

        backup_suffix=''
        if [ $OVERWRITE -eq 0 ]; then
            backup_suffix=.$$.bak
        fi
        sed -i$backup_suffix "$setup_cmd" "$local_file_path"
        

        # ========================= #
        # insert src file into local file
        # ========================= #

        sed -i "$append_line_num a \\\\" "$local_file_path"
        sed -i "$append_line_num r $file_path" "$local_file_path"
        ((installs++))
    
    else
        # local file doesn't exist; copy from src
        cp "$file_path" "$local_file_path"
    fi
done

echo '    -------- resources...'
RES_PREFIX=res
LOCAL_RES_DIR=$LOCAL_USER_PATH.resources
mkdir -p "$LOCAL_RES_DIR"
# iterate incoming resources
for file_path in $(find "$RES_PREFIX" -type f); do
    
    # define cooresponding local res path
    local_file_path=$LOCAL_RES_DIR${file_path#$RES_PREFIX}
    
    # if local res doesn't exist, install it
    if [ ! -f "$local_file_path" ]; then
        print_file_path
        [ $DRY -eq 1 ] && continue
        install_file
    fi
done
    
echo '    ---- done.'

# ========================= # 


# final stats ================================================================ #
echo "
Done.
src files installed: $installs
Local files backed up: $backups
Failures: $failures"
# ========================= # 


if [ $REFRESH_ONLY -eq 0 ] && [ $DRY -eq 0 ] && [ $failures -eq 0 ]; then
    echo '
    ** System integration successful; relog to apply group changes **'
fi
