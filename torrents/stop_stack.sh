#!/bin/bash

blue=`tput setaf 4`
red=`tput setaf 1`
green=`tput setaf 2`
yellow=`tput setaf 3`
txtund=`tput sgr 0 1`          # Underline
reset=`tput sgr0`


echo ${red} && echo "================ ${txtund}Stopping any torrent containers${reset}${red} ==================="
echo ${yellow}

echo ${yellow}
docker stop \
    vpn-torr \
    transmission \
    sonarr \
    radarr \
    jackett \
    bazarr \
    lazylibrarian \
    sabnzbd \
    couchpotato
  
echo ${blue}
docker rm -f -v \
    vpn-torr \
    transmission \
    sonarr \
    radarr \
    jackett \
    bazarr \
    lazylibrarian \
    sabnzbd \
    couchpotato 

echo ${reset}
