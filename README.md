# Setup instructions

## Environment details
- display manager: gdm3 (better compatibility than sddm)
- desktop environment: kde plasma
- window manager: i3

## OS setup resources
- swap: https://opensource.com/article/19/2/swap-space-poll
- uefi vs legacy/BIOS booting: http://www.rodsbooks.com/linux-uefi/
- kde plasma version heirarchy:
    - kde-full
    - kde-standard
    - kde-plasma-desktop

## Files
Clone repo and run install script. A relog/reboot is recommended to apply all configurations (not required on "file refresh"; see `install.sh --help` for more details).

## Display(s) configuration
### Position and scale
- via kde - System Settings
- via nvidia - Nvidia X Server Settings
    - if failing to write config, either copy raw output to file manually or
    try `sudo chmod u+x /usr/share/screen-resolution-extra/nvidia-polkit`
- via xrandr (recommended; most flexible) - add startup configuration commands to ~/.xprofile
    - rotate a display: `xrandr --output \<display\> --rotate \<direction\>`
    - scale a display: `xrandr --output \<display\> --scale \<Px\>x\<Py\> --fb \<Sx\>x\<Sy\> --pos \<Ox\>x\<Oy\>`
        - Px and Py: display picture width and height scalars, respectively
        - Sx and Sy: virtual screen width and height, respectively
        - Ox and Oy: display output absolute x and y positions within virtual screen, respectively  
        - When configuring multiple displays, do so with one `xrandr` call in which --fb is specified once and the --scale/--pos arguments are specified in sequential pairs for each display to configure
### i3 integration
One can assign i3 workspaces to specific displays. The provided config includes i3 commands for this purpose from ~/.local/i3/display_assignments.conf

## Security setup
### Fingerprint
1. `sudo apt install fprintd libpam-fprintd`
2. Add fingerprints via System Settings or `fprintd-enroll`
3. (opt) Check that prints work with `fprintd-verify`
### Facial rec
Install Howdy: https://github.com/boltgolt/howdy
- Outside of any virtual env, `sudo pip install dlib --break-system-packages`<sup>1</sup>
- Become root and navigate to /lib/security/howdy
    - `dlib-data/install.sh`
    - `chmod -R a+rx dlib-data models records`
    - `chmod -R a+rxw snapshots`
    - In compare.py, modify `import ConfigParser` to `import configparser as ConfigParser`<sup>1</sup><br>

<sup>1</sup>See https://github.com/boltgolt/howdy/issues/781 for more details
### Enable new auth methods
`pam-auth-update`

## System Settings
### Appearance
Global Theme: Breeze Dark (appearance and desktop/window layout)
### Workspace Behavior
- Desktop Effects
    - Zoom: no
- Screen Locking
    - never lock screen automatically
    - no keyboard shortcut
### Shortcuts
- disable all meta shortcuts; can ignore kwin since it will be replaced by i3wm
- Common Actions contains extra defaults; user discretion
    - (rec) Zoom In: Ctrl+=
### Startup and Shutdown
- Autostart: none
- Background Services: enable only:
    - Accounts
    - Automatic Location for Night Color
    - Gnome/GTK Settings Synchronization Service
    - Keyboard Daemon
    - Plasma Vault module
    - Removable Device Automounter
    - Search Folder Updater
    - SMART
    - Thunderbolt Device Monitor
    - Time Zone
    - (opt) Touchpad
    - Write Daemon
- Desktop Session: start an empty session
### Notifications
- Application-specific settings
    - Power Management: disable all event (battery only)
### KDE Wallet
- Access Control
    - Prompt when an application access a wallet: no
- KWalletManager: set empty password
### Input Devices
- Keyboard
    - Hardware
        - NumLock on Plasma Startup: Turn on
    - Advanced
        - Position of Compose key: Left Win
### Power Management
- Energy Saving
    - Screen Energy Saving: disable
    - Suspend Session: disable
    - Power Button: user discretion

## Other appearance settings
- `nitrogen` and set image to desired; see ~/.resources
- `konsole` 
    - Enable provided profile, set as default
    - Disable system and session toolbars
- `lxappearance` and set application theme to Breeze-Dark
    - **Also run as root to configure root applications (e.g., GParted)

## Other shortcuts
.shortcut files provided at repo root. Import them in their respective applications.

## Other software
- Jupyter notebook
    - Activate base conda env and `conda install nb_conda_kernels`
    - In new envs, `conda install ipykernel`
    - Start notebook servers from base env, then select desired kernel in target env

## Command Line Appendix
### Convert, file formats
- Documents: best to use online converter; yet to find good linux solution
- Images: 'magick <file>.<source format> <target name>.<target format>'
### DPI, global
- In ~/.Xresources, create/modify the line `Xft.dpi: <global dpi>`
- Ensure ~/.initrc has `xrdb -merge ~/.Xresources`
### gnome-shell, purge
1. `sudo apt remove ubuntu-desktop`
2. `sudo apt remove \*gnome\*`
    - If using gdm3, reinstall with `sudo apt install gdm3`
3. (opt) Remove all associated xsession configs from /usr/share/xsessions
### Keycodes
- `xev`
- `showkey`
### Packages, maintain multiple versions
'update-alternatives'

