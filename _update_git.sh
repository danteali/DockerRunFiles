#!/bin/bash

# Check running as root 
if [ $(id -u) -ne 0 ]; then tput setaf 1; echo "Not running as root, attempting to automatically restart script with root access..."; tput sgr0; echo; sudo $0 $*; exit 1; fi

cd /home/ryan/scripts/docker

git add .
git status
git commit -m "Latest Update"
git push origin master
