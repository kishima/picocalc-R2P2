#!/bin/bash

set -e

#pico-sdk 2.2.0 requried
rake picoruby:pico2:debug

# Find the generated ELF file (exclude pico-sdk subdirectory)
TARGET_ELF_FILE=$(find build/picoruby/pico2/debug -maxdepth 1 -name "R2P2-*.elf" -type f | head -1)
TARGET_UF2_FILE=$(find build/picoruby/pico2/debug -maxdepth 1 -name "R2P2-*.uf2" -type f | head -1)

if [[ -z "$TARGET_ELF_FILE" ]]; then
    echo "Error: No ELF file found in build/picoruby/pico2/debug"
    exit 1
fi

echo "Found ELF file: $TARGET_ELF_FILE"

if [[ "$1" == "flash" ]]; then
    openocd -f interface/cmsis-dap.cfg -f target/rp2350.cfg -c "adapter speed 2000" -c "program $TARGET_ELF_FILE verify reset exit"
    #USB MSC mode
    #sudo picotool load -v -x $TARGET_UF2_FILE
    #sudo picotool info -a
else
    echo "Build successful. Use './build.sh flash' to write to device."
fi
