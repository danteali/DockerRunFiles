#!/bin/bash

# Script to quickly run commands to ush updates to HomeAssistantConfig git repo

# Check running as root 
if [ $(id -u) -ne 0 ]; then tput setaf 1; echo "Not running as root, attempting to automatically restart script with root access..."; tput sgr0; echo; sudo $0 $*; exit 1; fi

cd /storage/Docker/home-assistant/config

sudo git add .
sudo git status
sudo git commit -m "Latest Update"
sudo git push origin master
