# Setup instructions
<br>
<br>

## Environment details
- display manager: gdm3 (better compatibility than sddm)
- desktop environment: kde
- window manager: i3

## OS setup resources
- swap: https://opensource.com/article/19/2/swap-space-poll
- uefi vs legacy/BIOS booting: http://www.rodsbooks.com/linux-uefi/

# Files
Clone repo and run install.sh. A reboot is required for all settings to take effect.

## Graphics drivers
- nvidia:
    - check for existing drivers (e.g., 'nvidia-smi'). Newer releases install automatically. If not installed, proceed.
    - find best \<version\> from https://www.nvidia.com/download/index.aspx
    - 'sudo apt install nvidia-driver-\<version\>'
    - reboot
## Display(s) configuration
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
**One can also assign i3 workspaces to specific displays. The provided config imports from ~/.local/i3/display_assignments.conf

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

## Other appearance settings
- nitrogen: set image to desired; see ~/.resources
- konsole: 
    - enable provided profile, set as default
    - disable system and session toolbars
    - import konsole.shortcuts (provided at root)
- lxappearance: set application theme to Breeze-Dark

## Other software
- jupyter notebook
    - activate base conda environ and ‘conda install nb_conda_kernels’
    - new environs: ‘conda install ipykernel’
    - start notebook server from base env, then select kernel from other envs in the gui

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
