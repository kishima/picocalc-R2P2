#!/bin/bash

set -e

cd build
make
cd ..
TARGET_ELF_FILE=picocalc_helloworld.elf 

if [[ "$1" == "flash" ]]; then
    openocd -f interface/cmsis-dap.cfg -f target/rp2350.cfg -c "adapter speed 2000" -c "program build/$TARGET_ELF_FILE verify reset exit"
else
    echo "Build successful. Use './build.sh flash' to write to device."
fi
