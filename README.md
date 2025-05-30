# Setup instructions


## Environment details
- display manager: gdm3 (better compatibility than sddm)
- desktop environment: kde plasma
- window manager: i3

<br></br>


## OS setup resources
- swap: https://opensource.com/article/19/2/swap-space-poll
- uefi vs legacy/BIOS booting: http://www.rodsbooks.com/linux-uefi/
- kde plasma version heirarchy:
    - kde-full
    - kde-standard
    - kde-plasma-desktop
    
<br></br>


## Install core applications
- chrome
- git
- vscode

<br></br>


## Files
Clone repo and run install.sh.

<br></br>


## Display(s) configuration
### Position and scale
- via kde - System Settings
- via nvidia - Nvidia X Server Settings
    - if failing to write config, either copy raw output to file manually or
    try `sudo chmod u+x /usr/share/screen-resolution-extra/nvidia-polkit`
- via xrandr (recommended) - to ~/.xprofile, append `xrandr [OPTION]`
    - rotate display: `--rotate <direction>`
    - individually scale display
        - set virtual screen dims: `--fb <virtual width>x<virtual height>`
        - for each display, set scale and position: `--output <display> --scale <scale x>x<scale y> --pos <pos x>x<pos y>`
### i3 integration
One can assign i3 workspaces to specific displays. The provided config includes i3 commands for this purpose from ~/.local/i3/display_assignments.conf

<br></br>


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

<br></br>


## System Settings
### Appearance
- Global Theme: Breeze Dark (appearance and desktop/window layout)
- Application Style > Configure GNOME/GTK Application Style... > GTK Theme: Breeze
### Workspace Behavior
General Behavior: Click files or folders: Selects them
### Shortcuts
Import \<top-level\>/shortcuts/system.kkrc via Import Schema...
### Startup and Shutdown
- Autostart: none
- Background Services > enable only:
    - Accounts
    - Automatic Location for Night Color
    - Gnome/GTK Settings Synchronization Service
    - Keyboard Daemon
    - Plasma Vault module
    - (opt) Removable Device Automounter
    - Search Folder Updater
    - SMART
    - Thunderbolt Device Monitor
    - Time Zone
    - Touchpad
    - Write Daemon
- Desktop Session: start an empty session
### Input Devices
- Keyboard
    - Hardware: NumLock on Plasma Startup: Turn on
    - Advanced: Position of Compose key: Left Win
- Mouse: Acceleration profile: Adaptive
- Touchpad
    - Pointer acceleration: 0.60
    - enable all Tapping options
    - Scrolling: Invert scroll direction

<br></br>


## Other settings
File manager places:
- Home
- Pictures
- Downloads
- Trash
- Desktop
- Music
- Videos
- debian-config
- projects

<br></br>


## Other appearance settings
- `nitrogen`: set image to desired; see ~/.resources
- `konsole` 
    - Enable provided profile, set as default
    - Disable system and session toolbars
- `code`
    - Left sidebar: enable only:
        - Explorer
        - Search
        - Source Control
        - Run and Debug
        - Extensions
        - (Note: New extensions will add themselves to the sidebar)
    - Source Control > Source Control: disable Gitlens's "Show Commit Graph"
    - Status Bar: enable only:
        - Problems
        - Debug
        - GitLens Current Line Blame
        - Editor Selection
        - Editor Indentation
        - Editor Encoding
        - Editor End of Line
        - Editor Language
        - Notifications

<br></br>


## Shortcuts
In \<top-level\>/shortcuts, import:
- system.kksrc via System Settings > Shortcuts > Import Schema...
- \<app name\>.shortcuts via \<app\> > Settings > Configure Keyboard Shortcuts... > Manage Schemas > More Actions > Import Schema...

<br></br>


## Other software
- Jupyter notebook
    - Activate base conda env and `conda install nb_conda_kernels`
    - In new envs, `conda install ipykernel`
    - Start notebook servers from base env, then select desired kernel in target env

<br></br>


## Shell Appendix

### Convert b/w file formats
- Documents: best to use online converter; yet to find good linux solution
- Images: `convert <file>.<source format> <target name>.<target format>` (from apt package imagemagick)

### DPI, set global
- In ~/.Xresources, create/modify the line `Xft.dpi: <global dpi>`
- Ensure ~/.initrc has `xrdb -merge ~/.Xresources`

### GNOME desktop environemnt, purge
1. `sudo apt remove ubuntu-desktop`
2. `sudo apt remove *gnome*`
    - If using gdm3, reinstall with `sudo apt install gdm3`
3. (opt) Remove all associated xsession configs from /usr/share/xsessions

### GRUB, set kernel params
1. /etc/default/grub: GRUB_CMDLINE_LINUX_DEFAULT:
    - "quiet splash"
    - "nomodeset"
    - ""
2. `sudo update-grub` (writes to /boot/grub/grub.cfg)

### Keycodes, show
- `xev`
- `showkey`


### Pipelines

Remember: pipes create asynchronous subshells. As with any other subshell, variable assignments occur within the subshell's scope and therefore have no effect in the parent shell.

Consider a common case in which this wrinkle becomes relevant: a `while read` loop at the end of a pipeline that iterates the pipeline's results. One must be sure that no commands following such a loop rely on variable assignments therein. 


### TLS certificates
- root CA: `openssl req -x509 -out rootCA.crt -keyout rootCA.key -noenc -days <valid days>`
- SAN-compliant certificate:
    - `openssl req -new -out <domain>.csr -keyout <domain>.key -noenc`
    - \<domain\>.ext:
        - authorityKeyIdentifier = keyid,issuer
        - basicConstraints = CA:FALSE
        - subjectAltName = @alt_names
        - [alt_names]
        - DNS.1 = \<domain\>
    - `openssl x509 -req -in <domain>.csr -CA <CA>.crt -CAkey <CA>.key -out <domain>.crt -days <valid days> -extfile <domain>.ext`
- package certificate and private key: `openssl pkcs12 -export -in <domain>.crt -inkey <domain>.key -out <domain>.p12`

### Package versions, maintain multiple
`update-alternatives`

### X11 windows
- properties: `xprop`
- info: `xwininfo`

<br></br>


## TODO
- programatic install:
    - System Settings
    - VSCode
- spotify pulseaudio sink input cleanup service
- update Jupyter instructions
