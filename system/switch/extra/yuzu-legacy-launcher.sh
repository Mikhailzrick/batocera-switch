#!/bin/bash

# Set environment variables
export XDG_MENU_PREFIX=batocera-
export XDG_CONFIG_DIRS=/etc/xdg
export XDG_CURRENT_DESKTOP=XFCE
export DESKTOP_SESSION=XFCE

# Additional setup scripts
/userdata/system/switch/extra/batocera-switch-mousemove.sh &
/userdata/system/switch/extra/batocera-switch-sync-firmware.sh

# Ensure necessary directories and symlinks exist
mkdir -p /userdata/system/configs/yuzu-legacy/keys /userdata/system/.local/share/yuzu-legacy/keys /userdata/system/configs/ryujinx-legacy/system /userdata/system/switch/logs
[ ! -L /userdata/system/configs/ryujinx/bis/user/save ] && mkdir -p /userdata/system/configs/ryujinx/bis/user/save && rsync -au /userdata/saves/ryujinx/ /userdata/system/configs/ryujinx/bis/user/save/
[ ! -L /userdata/system/configs/yuzu-legacy/nand/user/save ] && mkdir -p /userdata/system/configs/yuzu-legacy/nand/user/save && rsync -au /userdata/saves/yuzu-legacy/ /userdata/system/configs/yuzu-legacy/nand/user/save/
cp -rL /userdata/bios/switch/*.keys /userdata/system/configs/yuzu-legacy/keys/ 2>/dev/null
cp -rL /userdata/bios/switch/*.keys /userdata/system/.local/share/yuzu-legacy/keys/ 2>/dev/null
cp -rL /userdata/bios/switch/*.keys /userdata/system/configs/ryujinx-legacy/system/ 2>/dev/null

# Configure yuzu executable and logs
rm /usr/bin/yuzu-legacy /usr/bin/yuzu-legacy-room 2>/dev/null
ln -s /userdata/system/switch/yuzu-legacy /usr/bin/yuzu-legacy 2>/dev/null
cp /userdata/system/switch/extra/yuzu/yuzu-legacy-room /usr/bin/yuzu-legacy-room 2>/dev/null
log1=/userdata/system/switch/logs/yuzu-legacy-out.txt
log2=/userdata/system/switch/logs/yuzu-legacy-err.txt
rm -f "$log1" "$log2"

# Increase file descriptor limits
ulimit -H -n 819200
ulimit -S -n 819200

# Process ROM argument
rom="$(echo "$@" | sed 's,-f -g ,,g')"

# Launch yuzu
if [[ -z "$rom" ]]; then
    # No ROM provided, launch in default mode
    DRI_PRIME=1 AMD_VULKAN_ICD=RADV DISABLE_LAYER_AMD_SWITCHABLE_GRAPHICS_1=1 LC_ALL=C NO_AT_BRIDGE=1 \
    QT_FONT_DPI=96 QT_SCALE_FACTOR=1 GDK_SCALE=1 \
    LD_LIBRARY_PATH="/userdata/system/switch/extra/yuzu-legacy:${LD_LIBRARY_PATH}" \
    QT_PLUGIN_PATH=/usr/lib/qt/plugins:/userdata/system/switch/extra/lib/qt5plugins:/usr/plugins:${QT_PLUGIN_PATH} \
    QT_QPA_PLATFORM_PLUGIN_PATH=${QT_PLUGIN_PATH} \
    XDG_CONFIG_HOME=/userdata/system/configs XDG_CACHE_HOME=/userdata/system/.cache QT_QPA_PLATFORM=xcb \
    /userdata/system/switch/extra/yuzu-legacy/yuzu-legacy -f -g > >(tee "$log1") 2> >(tee "$log2" >&2)
else
    # ROM provided, handle and launch with ROM
    if [[ "$(echo "$rom" | rev | cut -c 1-4 | rev)" = ".nsz" ]] || if [[ "$(echo "$rom" | rev | cut -c 1-4 | rev)" = ".xcz" ]]; then
        rm /tmp/switchromname 2>/dev/null
        echo "$rom" > /tmp/switchromname
        /userdata/system/switch/extra/batocera-switch-nsz-converter.sh
        rom=$(< /tmp/switchromname)
    fi

    # Check file system type for ROM handling
    FS_TYPE=$(df -T /userdata | awk 'NR==2 {print $2}')
    if [[ "$FS_TYPE" = "ext4" || "$FS_TYPE" = "btrfs" ]]; then
        rm /tmp/yuzurom 2>/dev/null
        ln -sf "$rom" /tmp/yuzurom
        ROM="/tmp/yuzurom"
    else
        ROM="$rom"
    fi

    # Launch yuzu with ROM
    DRI_PRIME=1 AMD_VULKAN_ICD=RADV DISABLE_LAYER_AMD_SWITCHABLE_GRAPHICS_1=1 QT_XKB_CONFIG_ROOT=/usr/share/X11/xkb \
    LC_ALL=C.utf8 NO_AT_BRIDGE=1 XDG_MENU_PREFIX=batocera- XDG_CONFIG_DIRS=/etc/xdg XDG_CURRENT_DESKTOP=XFCE DESKTOP_SESSION=XFCE \
    QT_FONT_DPI=96 QT_SCALE_FACTOR=1 GDK_SCALE=1 \
    LD_LIBRARY_PATH="/userdata/system/switch/extra/yuzu-legacy:${LD_LIBRARY_PATH}" \
    QT_PLUGIN_PATH=/usr/lib/qt/plugins:/userdata/system/switch/extra/lib/qt5plugins:/usr/plugins:${QT_PLUGIN_PATH} \
    QT_QPA_PLATFORM_PLUGIN_PATH=${QT_PLUGIN_PATH} \
    XDG_CONFIG_HOME=/userdata/system/configs XDG_CACHE_HOME=/userdata/system/.cache QT_QPA_PLATFORM=xcb \
    /userdata/system/switch/extra/yuzu-legacy/yuzu-legacy -f -g "$ROM" > >(tee "$log1") 2> >(tee "$log2" >&2)
fi
