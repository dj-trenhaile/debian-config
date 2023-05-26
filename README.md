# Everything to setup an ubuntu install

### Flash usb and install ubuntu; transfer files if necessary
- swap: https://opensource.com/article/19/2/swap-space-poll
- uefi vs legacy/BIOS booting: http://www.rodsbooks.com/linux-uefi/

### enable ssh login
- apt install: openssh-server
- 'sudo systemctl enable ssh'

### Graphics drivers and display setup
- nvidia:
    - check for existing drivers (e.g., 'nvidia-smi'). Newer releases install automatically. If not installed, proceed.
    - find best \<version\> from https://www.nvidia.com/download/index.aspx
    - 'sudo apt install nvidia-driver-\<version\>'
    - reboot
    - 'sudo chmod u+x /usr/share/screen-resolution-extra/nvidia-polkit'
    - adjust displays as desired in Nvidia Settings and save config file
    - **NOTE: gnome overrides xorg.conf. If you wish to use ubuntu without i3, you will have to set the monitor configuration again via gnome-control-center

### Install chrome
- chrome://flags ⇒ smooth scrolling
- extensions
    - Dark Reader

### apt install essential software:
- brightnessctl (and modify group permissions to use it correctly:)
    - ‘sudo adduser $USER video’
    - ‘newgrp video’
- scrot
- gnome-screenshot
- net-tools
- pulseaudio
- pulseaudio-utils

### Security setup
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

### Setup window management and appearance
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

### Install other software
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

### (Opt) Modify power/thermal settings:
- CPU states: powerprofilesctl (recommend balanced default)
- bios-level (recommend optimized default)

### If desired, place ubuntu first in boot order

### Appendix
- showing keycodes
    - xev
    - showkey


### TODO: full run-through

