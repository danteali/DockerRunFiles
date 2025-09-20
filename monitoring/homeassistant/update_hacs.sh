#!/bin/bash

# Check running as root - needed for logrotation
    if [ $(id -u) -ne 0 ]; then tput setaf 1; echo "Not running as root, attempting to automatically restart script with root access..."; tput sgr0; echo; sudo $0 $*; exit 1; fi

# Download latest zip to tmp
    echo "Downloading latest HACS release ..."
    curl -s https://api.github.com/repos/hacs/integration/releases/latest | \
        grep "hacs.*zip" | \
        cut -d : -f 2,3 | \
        tr -d '"' | \
        sed -n 2p | \
        sudo xargs wget {} -O /tmp/hacs.zip

# Extract to ../config/customer_components/hacs/
    echo "Extracting hacs.zip to /storage/Docker/home-assistant/config/custom_components/hacs/ ..."
    sudo unzip -q -o /tmp/hacs.zip -d /storage/Docker/home-assistant/config/custom_components/hacs/
