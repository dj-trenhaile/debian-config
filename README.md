# Everything to setup an ubuntu install
<br>
<br>

## Flash usb and install ubuntu; transfer files if necessary
- swap: https://opensource.com/article/19/2/swap-space-poll
- uefi vs legacy/BIOS booting: http://www.rodsbooks.com/linux-uefi/

## enable ssh login
- apt install: openssh-server
- 'sudo systemctl enable ssh'

## Graphics drivers
- nvidia:
    - check for existing drivers (e.g., 'nvidia-smi'). Newer releases install automatically. If not installed, proceed.
    - find best \<version\> from https://www.nvidia.com/download/index.aspx
    - 'sudo apt install nvidia-driver-\<version\>'
    - reboot
## Configuring displays
For most display configurations, the tool packaged with your graphics drivers is sufficient and most convenient. However, running xrandr commands at X server start time offers the most flexiblity and compatibility with i3. For exmaple, configurations that require display-specific scaling are only possible via xrandr. 

- nvidia - Nvidia X Server Settings
    - 'sudo chmod u+x /usr/share/screen-resolution-extra/nvidia-polkit'
    - adjust displays via nvidia-settings and save config file 
  
**Note: gnome overrides xorg.conf. To use ubuntu without i3, set the display configuration via gnome-control-center instead.
<br>
<br>
- xrandr - add desired commands to ~/.xprofile:
    - rotate a display: 'xrandr --output \<display\> --rotate \<direction\>'
    - scale a display: 'xrandr --output \<display\> --scale \<Px\>x\<Py\> --fb \<Sx\>x\<Sy\> --pos \<Ox\>x\<Oy\>' where:
        - Px and Py: display picture width and height scalars, respectively
        - Sx and Sy: virtual screen width and height, respectively
        - Ox and Oy: display output absolute x and y positions within virtual screen, respectively  
        - **Note: chain addition sets of the above parameters in one command when configuring multiple displays. Set --fb only once. 

You can also combine these settings with a global DPI setting.
- 'echo "Xft.dpi: \<desired global dpi\>" > ~/.Xresources'
- create/modify .xinitrc:
    - xrdb -merge ~/.Xresources
    - exec i3

## Install chrome
- chrome://flags ⇒ smooth scrolling
- extensions
    - Dark Reader

## apt install essential software:
- brightnessctl (and modify group permissions to use it correctly:)
    - ‘sudo adduser $USER video’
    - ‘newgrp video’
- scrot
- gnome-screenshot
- net-tools
- pulseaudio
- pulseaudio-utils

## Security setup
- fingerprint
    - apt install:
        - fprintd
        - libpam-fprintd
    - add fingerprints via gnome-control-center or fprintd-enroll
    - (opt) check that prints work with fprintd-verify
- facial rec
    - install howdy: https://github.com/boltgolt/howdy
    - apt install: 
        - opencv-python
        - ‘sudo pip install dlib --break-system-packages’ (outside of any virtual env) **
    - become root and navigate to install location at /lib/security/howdy:
        - run install.sh in dlib-data
        - chmod -R a+rx:
            - dlib-data
            - models
            - recorders
        - chmod -R a+rxw:
            - snapshots
        - compare.py: import ConfigParser >> import configparser as ConfigParser **
    - ** see https://github.com/boltgolt/howdy/issues/781 for more details
- enable new auth methods via pam-auth-update

## Setup window management and appearance
- apt install:
    - i3 
    - polybar
    - rofi
    - picom
    - nitrogen
    - libinput-tools (uses config in xorg.conf.d to fix trackpad issues)
    - blueman
- clone this repo, move all files in fs to corresponding places in your filesystem
- other setup:
    - polybar: install nerd font symbols
        - download from https://github.com/ryanoasis/nerd-fonts/blob/master/patched-fonts/3270
        - move complete.ttf to /usr/share/fonts/truetype/nerdfonts
        - ‘fc-cache -vf /usr/share/fonts’
    - nitrogen: set image to desired (see wallpapers at root)
- reboot

## Install other software
- apt: 
    - xdotool (manipulates windows in Xorg)
    - xclip (pipe command line output directly to clipboard: '... | xclip -selection clipboard')
    - ffmpeg
- snap:
    - vscode; extensions:
        - Open Folder Context Menus for VS Code
        - GitLens
    - pycharm
    - spotify
    - orange-app (soundcloud client)
- anaconda
    - recommended: https://github.com/conda-forge/miniforge#mambaforge
    - recommended work flow:
        - create new environments in the current project directory: ‘conda create --prefix ./.env’
        - to activate them: ‘conda activate ./.env’
        - eliminate long absolute path from environment prompt: ‘conda config --set env_prompt ‘({name})’’
- jupyter notebook
    - activate base conda environ and ‘conda install nb_conda_kernels’
    - new environs: ‘conda install ipykernel’
    - start notebook server from base env, then select kernel from other envs in the gui

## (Opt) Modify power/thermal settings:
- CPU states: powerprofilesctl (recommend balanced default)
- bios-level (recommend optimized default)

## If desired, place ubuntu first in boot order

## Appendix
- showing keycodes
    - xev
    - showkey


## TODO: full run-through

