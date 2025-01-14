#!/bin/bash
################################################################################
# v1.0                SWITCH EMULATORS UPDATER FOR BATOCERA                    #
#                   ----------------------------------------                   #
#                   > github.com/mikhailzrick/batocera-switch                  #
################################################################################

ORIGIN="https://raw.githubusercontent.com/mikhailzrick/batocera-switch/main"
BASE_DIR="/userdata/system/switch"
EXTRA_DIR="$BASE_DIR/extra"
LOG_DIR="$BASE_DIR/logs"
APP_DIR="/usr/share/applications"
TEMP_DIR="/tmp/switch/downloads"

# Directories to create
declare -a DIRECTORIES=(
    "$BASE_DIR"
    "$EXTRA_DIR"
    "$LOG_DIR"
    "$TEMP_DIR"
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

start_installation() {
    # Create directories
    for dir in "${DIRECTORIES[@]}"; do
        mkdir -p "$dir"
    done

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
            echo -e "\nError: Failed to download $url." >&2
            sleep 3
            exit 1
        fi
    done
    echo -ne "\rProgress: 100%\n"
}

# Generate desktop shortcuts
generate_shortcut() {
    local name="$1"
    local icon="$2"
    local exec="$3"
    local shortcut_file="$APP_DIR/$name.desktop"

    rm -f "$shortcut_file" 2>/dev/null
    {
        echo "[Desktop Entry]"
        echo "Version=1.0"
        echo "Icon=$icon"
        echo "Exec=$exec"
        echo "Terminal=false"
        echo "Type=Application"
        echo "Categories=Game;batocera.linux;"
        echo "Name=$name-config"
    } > "$shortcut_file"

    chmod +x "$shortcut_file" 2>/dev/null
}

install_yuzu_legacy() {
    local link_yuzu_legacy="/userdata/system/switch/yuzuea4176.AppImage" # Latest version (legacy)
    local checksum_verified="9f20b0e6bacd2eb9723637d078d463eb"

    # Files to download
    local -A YUZU_LEGACY_FILES_TO_DOWNLOAD=(
        ["$BASE_DIR/configgen/generators/yuzu-legacy/yuzuLegacyGenerator.py"]="$ORIGIN/system/switch/configgen/generators/yuzu-legacy/yuzuLegacyGenerator.py"
        ["$BASE_DIR/configgen/generators/yuzu-legacy/__init__.py"]="$ORIGIN/system/switch/configgen/generators/yuzu-legacy/__init__.py"
        ["$BASE_DIR/yuzu-legacy-launcher.sh"]="$ORIGIN/system/switch/extra/yuzu-legacy-launcher.sh"
        ["$EXTRA_DIR/batocera-config-yuzu-legacy"]="$ORIGIN/system/switch/extra/batocera-config-yuzu-legacy"
        ["$EXTRA_DIR/yuzu-legacy.png"]="$ORIGIN/system/switch/extra/yuzu-legacy.png"
    )

    # Verify if the AppImage exists and has the correct checksum
    if [[ -f "$link_yuzu_legacy" ]]; then
        chmod +x "$link_yuzu_legacy"
        local checksum_file
        checksum_file=$(md5sum "$link_yuzu_legacy" | awk '{print $1}')

        if [[ "$checksum_file" != "$checksum_verified" ]]; then
            echo "Checksum mismatch. Skipping yuzu-legacy installation."
            return 1
        fi
    else
        echo "Valid AppImage not found. Place 'yuzuea4176.AppImage' in /userdata/system/switch/"
        return 1
    fi

    # Prepare directories
    mkdir -p "$BASE_DIR/configgen/generators/yuzu-legacy"
    mkdir -p "$TEMP_DIR/yuzu_legacy/"

    echo "Downloading yuzu-legacy files..."
    local total_files=${#YUZU_LEGACY_FILES_TO_DOWNLOAD[@]}
    local completed_files=0

    # Download files with progress
    for file_path in "${!YUZU_LEGACY_FILES_TO_DOWNLOAD[@]}"; do
        local url="${YUZU_LEGACY_FILES_TO_DOWNLOAD[$file_path]}"
        if wget -q --tries=5 --no-check-certificate -O "$file_path" "$url"; then
            ((completed_files++))
            local progress=$((completed_files * 100 / total_files))
            echo -ne "\rProgress: $progress% \r"
        else
            echo -e "\nError: Failed to download $url." >&2
            return 1
        fi
    done
    echo -ne "\rProgress: 100%\n"

    echo "Starting installation of yuzu-legacy. Please wait..."

    # Extract and install yuzu-legacy AppImage
    cp "$link_yuzu_legacy" "/userdata/system/switch/extra/backup" 2>/dev/null
    mv "$link_yuzu_legacy" "$TEMP_DIR/yuzu_legacy/yuzuea4176.AppImage"
    cd "$TEMP_DIR/yuzu_legacy"
    ./yuzuea4176.AppImage --appimage-extract >/dev/null 2>&1

    local yuzu_legacy_extract_dir="$TEMP_DIR/yuzu_legacy/squashfs-root"
    mkdir -p /userdata/system/switch/extra/yuzu-legacy

    # Copy necessary files
    cp "$yuzu_legacy_extract_dir/usr/lib/libQt5"* /userdata/system/switch/extra/yuzu-legacy/ 2>/dev/null
    cp "$yuzu_legacy_extract_dir/usr/lib/libcrypto"* /userdata/system/switch/extra/yuzu-legacy/ 2>/dev/null
    cp "$yuzu_legacy_extract_dir/usr/lib/libssl"* /userdata/system/switch/extra/yuzu-legacy/ 2>/dev/null
    cp "$yuzu_legacy_extract_dir/usr/lib/libicu"* /userdata/system/switch/extra/yuzu-legacy/ 2>/dev/null
    cp "$yuzu_legacy_extract_dir/usr/bin/yuzu" /userdata/system/switch/extra/yuzu-legacy/yuzu-legacy 2>/dev/null
    cp "$yuzu_legacy_extract_dir/usr/bin/yuzu-room" /userdata/system/switch/extra/yuzu-legacy/yuzu-legacy-room 2>/dev/null

    # Add optional libraries
    cp "$yuzu_legacy_extract_dir/usr/optional/libstdc++/libstdc++.so.6" /userdata/system/switch/extra/yuzu-legacy/libstdc++.so.6
    cp "$yuzu_legacy_extract_dir/usr/optional/libgcc_s/libgcc_s.so.1" /userdata/system/switch/extra/yuzu-legacy/libgcc_s.so.1
    cp "$yuzu_legacy_extract_dir/usr/optional/exec.so" /userdata/system/switch/extra/yuzu-legacy/exec.so
    chmod +x /userdata/system/switch/extra/yuzu-legacy/lib* 2>/dev/null
    chmod +x "/userdata/system/switch/extra/yuzu-legacy/yuzu-legacy" 2>/dev/null
    chmod +x "/userdata/system/switch/extra/yuzu-legacy/yuzu-legacy-room" 2>/dev/null

    # Rename the launcher script
    mv "$BASE_DIR/yuzu-legacy-launcher.sh" "$BASE_DIR/yuzu-legacy"

    # Generate desktop shortcut
    generate_shortcut "yuzu-legacy" "$EXTRA_DIR/yuzu-legacy.png" "$BASE_DIR/yuzu-legacy"

    echo "yuzu-legacy installation completed."

    cd ~/
}

update_emulators() {

    install_yuzu_legacy

    #path_ryujinx=/userdata/system/switch/ryujinx-legacy.AppImage

    #link_ryujinx_legacy="/userdata/system/switch/appimages/ryujinxava1403.tar.gz" # Latest version (Legacy)

    #["$BASE_DIR/configgen/generators/ryujinx-legacy/ryujinxLegacyGenerator.py"]="$ORIGIN/system/switch/configgen/generators/ryujinx/ryujinxLegacyGenerator.py"
    #["$BASE_DIR/configgen/generators/ryujinx-legacy/__init__.py"]="$ORIGIN/system/switch/configgen/generators/ryujinx/__init__.py"
    #["$EXTRA_DIR/batocera-config-ryujinx-legacy"]="$ORIGIN/system/switch/extra/batocera-config-ryujinx-legacy"
    #["$EXTRA_DIR/ryujinx-legacy.png"]="$ORIGIN/system/switch/extra/ryujinx-legacy.png"
}

start_installation
update_emulators

exit 0
