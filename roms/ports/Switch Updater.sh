#!/bin/bash
#####################################################################
#                      PORTS: SWITCH UPDATER                        #
#                  -----------------------------                    #
#              > github.com/mikhailzrick/batocera-switch            #
#####################################################################

# Determine text size based on resolution
determine_text_size() {
    # Get resolution
    local resolution=$(xrandr | grep '*' | awk '{print $1}')

    # Determine text size based on common resolutions
    case "$resolution" in
        "640x480") # 480p
            TEXT_SIZE=16
            ;;
        "1280x720") # 720p
            TEXT_SIZE=20
            ;;
        "1920x1080") # 1080p
            TEXT_SIZE=24
            ;;
        "2560x1440") # 1440p
            TEXT_SIZE=28
            ;;
        "3840x2160") # 4k
            TEXT_SIZE=32
            ;;
        *) # Default text size for unknown resolutions
            TEXT_SIZE=10
            ;;
    esac
}

# Check if x86_64
ARCH=$(uname -m)
if [[ "$ARCH" != "x86_64" ]]; then
    curl http://localhost:1234/messagebox -d "ERROR: Detected architecture is $ARCH. Installation requires x86_64."
    exit 1
fi

# Check if file system supports symlinks
FS_TYPE=$(df -T /userdata | awk 'NR==2 {print $2}')
if [[ "$FS_TYPE" != "ext4" && "$FS_TYPE" != "btrfs" ]]; then
    curl http://localhost:1234/messagebox -d "ERROR: File system type ($FS_TYPE) does not support symlinks."
    exit 1
fi

updater="/userdata/system/switch/extra/batocera-switch-updater.sh"

# Remove any existing updater file
rm "$updater" 2>/dev/null

# Attempt to download the updater script
if wget -q --tries=5 --no-check-certificate --no-cache --no-cookies -O "$updater" "https://raw.githubusercontent.com/mikhailzrick/batocera-switch/main/system/switch/extra/batocera-switch-updater.sh"; then
    # Check for best font size
    determine_text_size

    # Launch xterm
    DISPLAY=:0.0 unclutter-remote -h
    DISPLAY=:0.0 LC_ALL=C xterm -maximized -fs "$TEXT_SIZE" -fg white -bg black -fa "DejaVuSansMono" -e bash "$updater"
else
    curl http://localhost:1234/messagebox -d "Error: Connection failed."
fi

exit 0
