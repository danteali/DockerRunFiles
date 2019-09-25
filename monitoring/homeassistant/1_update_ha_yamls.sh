#!/bin/bash
    red=`tput setaf 1`
    green=`tput setaf 2`
    yellow=`tput setaf 3`
    blue=`tput setaf 4`
    magenta=`tput setaf 5`
    cyan=`tput setaf 6`
    under=`tput sgr 0 1`
    reset=`tput sgr0`

# Most people probably won't need this script but I'm having permission issues so this is my 
# workaround

# There's probably an easier/better way to do this but this works for me and is quick.

# The config directory used by Home Assistant is hosted locally on this server. All the files are
# by default owned by root:root (I don't think this is the case in most other installations but 
# don't know why it is the case for me - don't want to change it in case it causes security 
# weaknesses through web frontend)
# So editing these is a pain in the ass. I like to edit in SublimeText on my desktop/laptop by 
# double clicking in the file browser of my SSH client (MobaXterm). This opens the files for editing
# but when it tries to save them it obviously throws an error since it can't save to a root owned 
# file. 
# So instead I create copies of the .yaml config files with extension .yaml2 and with permission for
# my user to edit them. So I can now save my changes. This script checks in bulk for any updated 
# .yaml2 files and copies them back over the .yaml files and retains the root ownership.



# Check running as root - attempt to restart with sudo if not already running with root
if [ $(id -u) -ne 0 ]; then 
    if [[ $VERBOSE = 1 ]]; then 
        tput setaf 1
        echo "Not running as root, attempting to automatically restart script with root access..."
        tput sgr0
        echo
    fi
    sudo $0 $*
    exit 1
fi

DIRCONFIG="/storage/Docker/home-assistant/config"

DRYRUN=0


if [[ $* == *"-v"* ]]; then
    VERBOSE=1
fi

if [[ $* == *"--dry-run"* ]]; then
    DRYRUN=1
    echo
    echo "${yellow}Dry running...${reset}"
    echo
fi

# Loop through all files & folders and find any *.yaml2
#find $DIRCONFIG -maxdepth 1 -type f -name "*.yaml2" | \
find $DIRCONFIG -type f -name "*.yaml2" | \
while read -r files; do
    DESTFILENAME="${files%?}"
    if [[ $VERBOSE = 1 ]]; then echo; echo "${blue}Found... $files${reset}"; fi
    # if the corresponding *.yaml exists then test for changes...
    if [[ -f $DESTFILENAME ]]; then
        if [[ $VERBOSE = 1 ]]; then echo "${cyan}Corresponding '.yaml' file exists. Checking for differences...${reset}"; fi
        if cmp -s "$files" "$DESTFILENAME"; then
            if [[ $VERBOSE = 1 ]]; then echo "${green}No Changes Found!${reset}"; fi
        else
            if [[ $VERBOSE = 1 ]]; then echo "${red}Changes Detected!${reset}"; fi
            if [[ ! $DRYRUN == 1 ]]; then
                echo "${red}Copying $files ...${reset}"
                sudo cp "$files" "$DESTFILENAME"
            fi
        fi
    else
        if [[ $VERBOSE = 1 ]]; then echo "${yellow}Corresponding '.yaml' file doesn't already exist.${reset}"; fi
    fi
done


# Delete known_devices.yaml2 and google_calendars.yaml2 since we don't want to continually overwrite any newly discovered devices or calendars
KNOWN_DEV2=/storage/Docker/home-assistant/config/known_devices.yaml2
if [[ -f "$KNOWN_DEV2" ]]; then 
    if [[ $VERBOSE = 1 ]]; then 
        echo
        echo "${magenta}Deleting known_devices.yaml2...${reset}"
        echo
    fi
    sudo rm $KNOWN_DEV2 > /dev/null 2>&1
fi
KNOWN_DEV2=/storage/Docker/home-assistant/config/google_calendars.yaml2
if [[ -f "$KNOWN_DEV2" ]]; then 
    if [[ $VERBOSE = 1 ]]; then 
        echo
        echo "${magenta}Deleting google_calendars.yaml2...${reset}"
        echo
    fi
    sudo rm $KNOWN_DEV2 > /dev/null 2>&1
fi

exit 0