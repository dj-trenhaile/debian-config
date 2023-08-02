# Everything to setup an ubuntu install
<br>
<br>

## Environment details:
- display manager: gdm3 (better compatibility than sddm)
- desktop environment: kde
- window manager: i3

## Flash usb and install ubuntu; transfer files if necessary
- swap: https://opensource.com/article/19/2/swap-space-poll
- uefi vs legacy/BIOS booting: http://www.rodsbooks.com/linux-uefi/

## Graphics drivers
- nvidia:
    - check for existing drivers (e.g., 'nvidia-smi'). Newer releases install automatically. If not installed, proceed.
    - find best \<version\> from https://www.nvidia.com/download/index.aspx
    - 'sudo apt install nvidia-driver-\<version\>'
    - reboot
## Configure displays
- via kde - System Settings
- via nvidia - Nvidia X Server Settings
    - if failing to write config, either copy raw output to file manually or
    try 'sudo chmod u+x /usr/share/screen-resolution-extra/nvidia-polkit'
- via xrandr - add desired commands to ~/.xprofile:
    - rotate a display: 'xrandr --output \<display\> --rotate \<direction\>'
    - scale a display: 'xrandr --output \<display\> --scale \<Px\>x\<Py\> --fb \<Sx\>x\<Sy\> --pos \<Ox\>x\<Oy\>' where:
        - Px and Py: display picture width and height scalars, respectively
        - Sx and Sy: virtual screen width and height, respectively
        - Ox and Oy: display output absolute x and y positions within virtual screen, respectively  
        - **Note: chain addition sets of the above parameters in one command when configuring multiple displays. Set --fb only once. 

## Security setup
- fingerprint
    - apt install:
        - fprintd
        - libpam-fprintd
    - add fingerprints via System Settings or fprintd-enroll
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

## System Settings
- Appearance
    - Global Theme: Breeze Dark (appearance and desktop/window layout)
- Workspace Behavior
    - Desktop Effects
        - Zoom: no
    - Screen Locking
        - never lock screen automatically
        - no keyboard shortcut
- Shortcuts
    - disable all meta shortcuts; can ignore kwin since it will be replaced by i3wm
    - Common Actions contains extra defaults that are not needed; user discretion
- Startup and Shutdown
    - Autostart: none
    - Background Services: enable only:
        - Automatic Location for Night Color
        - Gnome/GTK Settings Synchronization Service
        - Plasma Vault module
        - Removable Device Automounter
        - Search Folder Updater
        - SMART
        - Thunderbolt Device Monitor
        - Time Zone
        - (opt) Touchpad
        - Write Daemon
    - Desktop Session: start an empty session
- Notifications
    - Application-specific settings
        - Power Management: disable all event (battery only)
- KDE Wallet: disable
- Power Management
    - Energy Saving
        - Screen Energy Saving: disable
        - Suspend session: disable
        - power button: user discretion

## Configure .profile
- 'export TERMINAL=konsole'
- 'export COMPOSITOR_LAUNCH_LOCK=/var/lock/compositor_launch.lock'
- 'export POLYBAR_VARS=/tmp/polybar_vars.txt'
- 'export POLYBAR_LAUNCH_LOCK=/var/lock/polybar_launch.lock'

## Setup window management and appearance
- apt install:
    - i3 
    - polybar
    - rofi
    - picom
    - nitrogen
    - libinput-tools (uses config in xorg.conf.d to fix trackpad issues)
    - blueman
    - lxappearance
- clone this repo, move all files in fs to corresponding places in your filesystem
- other setup:
    - polybar: install nerd font symbols
        - download from https://github.com/ryanoasis/nerd-fonts/blob/master/patched-fonts/3270
        - move complete.ttf to /usr/share/fonts/truetype/nerdfonts
        - ‘fc-cache -vf /usr/share/fonts’
    - nitrogen: set image to desired (see wallpapers at root)
    - konsole: 
        - enable provided profile, set as default
        - disable system and session toolbars
        - import konsole.shortcuts
    - lxappearance: set application theme to Breeze-Dark
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
        - VS Color Picker
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

## Configure application settings with dconf
Some GTK applications read runtime settings from a read-optimized key-value 
binary file (located at ~/.config/dconf/user) of type GVariant Database (gvdb). 
These settings can be modified with dconf (cli) or dconf-editor (gui). 
- disable blueman notifications: /org/blueman/general/plugin-list -> ['!ConnectionNotifier']

## (Opt) Modify power/thermal settings:
- CPU states: powerprofilesctl (recommend balanced default)
- bios-level (recommend optimized default)

## If desired, place ubuntu first in boot order

## Appendix
- showing keycodes
    - xev
    - showkey
- setting global dpi:
    -  'echo "Xft.dpi: \<desired global dpi\>" > ~/.Xresources'
    -  create/modify .xinitrc:
        - xrdb -merge ~/.Xresources
        - exec i3
- Desktop sessions are stored as .desktop file in /usr/share/xsessions and can 
be modified similarly to .service files; kde example:
    [Desktop Entry]
    Type=XSession
    Exec=/usr/bin/startplasma-x11
    DesktopNames=KDE
    Name=Plasma (X11)


## TODO: full run-through

