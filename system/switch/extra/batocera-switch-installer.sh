#!/bin/bash

APPNAME="SWITCH-EMULATION"
ORIGIN="https://raw.githubusercontent.com/mikhailzrick/batocera-switch/main"

BASE_DIR="$BASE_DIR"
EXTRA_DIR="$BASE_DIR/extra"
LOG_DIR="$BASE_DIR/logs"

# Directories to create
declare -a DIRECTORIES=(
    "$BASE_DIR"
    "$EXTRA_DIR"
    "$LOG_DIR"
    "$EXTRA_DIR/backup"
    "$BASE_DIR/configgen"
    "$BASE_DIR/configgen/generators"
    "/userdata/roms/switch"
    "/userdata/roms/ports"
    "/userdata/roms/ports/images"
    "/userdata/bios/switch"
    "/userdata/bios/switch/firmware"
    "/userdata/system/configs"
    "/userdata/system/configs/emulationstation"
    "/userdata/system/configs/evmapy"
)

# File download paths and URLs
declare -A FILES_TO_DOWNLOAD=(
    # Lib files
    #["$EXTRA_DIR/libs/libselinux.so.1"]="$ORIGIN/system/switch/extra/libs/libselinux.so.1"
    #["$EXTRA_DIR/libs/libthai.so.0.3"]="$ORIGIN/system/switch/extra/libs/libthai.so.0.3"
    #["$EXTRA_DIR/libs/libtinfo.so.6"]="$ORIGIN/system/switch/extra/libs/libtinfo.so.6"
    #["$EXTRA_DIR/libs/libthai.so.0.3.1"]="$ORIGIN/system/switch/extra/libs/libthai.so.0.3.1"
    # Configgen generators
    ["$BASE_DIR/configgen/generators/Generator.py"]="$ORIGIN/system/switch/configgen/generators/Generator.py"
    ["$BASE_DIR/configgen/generators/__init__.py"]="$ORIGIN/system/switch/configgen/generators/__init__.py"
    # Configgens
    ["$BASE_DIR/configgen/GeneratorImporter.py"]="$ORIGIN/system/switch/configgen/GeneratorImporter.py"
    ["$BASE_DIR/configgen/switchlauncher.py"]="$ORIGIN/system/switch/configgen/switchlauncher.py"
    # EmulationStation
    ["/userdata/system/configs/emulationstation/es_systems_switch.cfg"]="$ORIGIN/system/configs/emulationstation/es_systems_switch.cfg"
    ["/userdata/system/configs/emulationstation/es_features_switch.cfg"]="$ORIGIN/system/configs/emulationstation/es_features_switch.cfg"
    # Evmapy configuration
    ["/userdata/system/configs/evmapy/switch.keys"]="$ORIGIN/system/configs/evmapy/switch.keys"
    # Ports script and images
    ["/userdata/roms/ports/Switch Updater.sh"]="$ORIGIN/roms/ports/Switch Updater.sh"
    ["/userdata/roms/ports/images/Switch Updater-boxart.png"]="$ORIGIN/roms/ports/images/Switch Updater-boxart.png"
    ["/userdata/roms/ports/images/Switch Updater-cartridge.png"]="$ORIGIN/roms/ports/images/Switch Updater-cartridge.png"
    ["/userdata/roms/ports/images/Switch Updater-mix.png"]="$ORIGIN/roms/ports/images/Switch Updater-mix.png"
    ["/userdata/roms/ports/images/Switch Updater-screenshot.png"]="$ORIGIN/roms/ports/images/Switch Updater-screenshot.png"
    ["/userdata/roms/ports/images/Switch Updater-wheel.png"]="$ORIGIN/roms/ports/images/Switch Updater-wheel.png"
    # Info
    ["/userdata/roms/switch/_info.txt"]="$ORIGIN/roms/switch/_info.txt"
    ["/userdata/bios/switch/_info.txt"]="$ORIGIN/bios/switch/_info.txt"
)

# Start installation
echo "--------------------------------"
echo "$APPNAME INSTALLER"
echo "--------------------------------"
echo

start_installation() {
    echo "Starting installation..."

    # Check if x86_64
    ARCH=$(uname -m)
    if [[ "$ARCH" != "x86_64" ]]; then
        echo "ERROR: Detected architecture is $ARCH. Installation requires x86_64. Exiting..."
        sleep 3
        exit 1
    fi

    # Check if file system supports symlinks
    FS_TYPE=$(df -T /userdata | awk 'NR==2 {print $2}')
    if [[ "$FS_TYPE" != "ext4" && "$FS_TYPE" != "btrfs" ]]; then
        echo "ERROR: File system type ($FS_TYPE) does not support symlinks. Exiting..."
        sleep 3
        exit 1
    fi

    # Create directories
    for dir in "${DIRECTORIES[@]}"; do
        mkdir -p "$dir"
    done

    echo "Directories created."
}

# Download Files
download_files() {
    echo "Downloading system files..."

    total_files=${#FILES_TO_DOWNLOAD[@]}
    completed_files=0

    # Download files and show progress
    for file_path in "${!FILES_TO_DOWNLOAD[@]}"; do
        url="${FILES_TO_DOWNLOAD[$file_path]}"

        # Download the file
        if wget -q --tries=5 --no-check-certificate -O "$file_path" "$url"; then
            ((completed_files++))

            progress=$((completed_files * 100 / total_files))
            echo -ne "\rProgress: $progress% \r"
        else
            sleep 3
            echo -e "\nError: Failed to download $url." >&2
            exit 1
        fi
    done
    echo -ne "\rProgress: 100%\n"
}

# Final confirmation
finalize_installation() {
    echo "--------------------------------"
    echo "$APPNAME INSTALLATION COMPLETE"
    echo "--------------------------------"
    echo
    echo "All necessary files and directories have been set up."
    echo "To update emulators, use the 'Switch Updater' in Ports."
    echo "Ensure all necessary BIOS and firmware files are in the correct directories:"
    echo "- BIOS: /userdata/bios/switch/"
    echo "- Firmware: /userdata/bios/switch/firmware/"
    echo
    echo "Use Switch Updater in Ports to update emulators."
    echo "Installation process complete. Enjoy!"
}

start_installation
download_files
finalize_installation

echo -n "Launching Switch Updater in "
for i in {3..1}; do
    echo -ne "\rLaunching Switch Updater in $i... "  # Overwrite the line
    sleep 1
done

# Launch the Switch Updater script
bash "/userdata/roms/ports/Switch Updater.sh"

exit 0
