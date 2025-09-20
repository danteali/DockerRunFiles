#!/bin/bash

## Script to check for completed downloads and remove from transmission
## Also check for running transmission container with a GB IP address
## Kill transmission if it's IP is in GB.

blue=`tput setaf 4`
red=`tput setaf 1`
green=`tput setaf 2`
yellow=`tput setaf 3`
txtund=`tput sgr 0 1`          # Underline
txtbld=`tput bold`             # Bold
reset=`tput sgr0`

SOURCE="/home/ryan/scripts/docker/torrents"

echo
# Check if transmission container running. Assume that if not running then monitor not needed.
if [ ! -z "$(docker ps | grep transmission | grep Up)" ]; then
  echo "${green}transmission container running - checking for completed torrents...${reset}" && echo

  #Check for completed torrents
  docker exec transmission /config/transmission_remove_completed

  #Check transmission container IP address. If not 'GB' then okay to be running. Otherwise kill.
  docker run --rm --net=container:transmission appropriate/curl curl -s ipinfo.io > $SOURCE/transmission_ip.tmp
  IP=`cat $SOURCE/transmission_ip.tmp | grep -e \"ip | tr -d '\n\r ,"ip:'`
  CO=`cat $SOURCE/transmission_ip.tmp | grep -e country | tr -d '", ' | sed 's/country://'`
  echo "${blue}Transmission IP Address: $IP"
  echo "Transmission Country: $CO ${reset}" && echo
  rm $SOURCE/transmission_ip.tmp

  if [[ $PIACO != *"GB"* ]]; then
    echo "${green}Transmission IP not in GB - VPN connected${reset}"
    exit 0
  else
    echo "${red}Transmission IP in GB - VPN not connected - killing transmission container${reset}"
    docker rm -f -v transmission
    #pushbullet "Transmission VPN disconnected - transmission stopped" "Disconnection noted at `date`. Killed transmission"
    pushover -c "media_stack" -T "Transmission VPN disconnected - transmission stopped" -m "Disconnection noted at `date`. Killed transmission"
    slack -u torrent_stack -c "#media_stack" -t "VPN NOT CONNECTED - KILLING TRANSMISSION" -e :arrow_double_down:

    # Also remove transmisson monitor for Grafana stats
    docker rm -f -v dockprom-transmission-exporter > /dev/null 2>&1
    
    exit 1
  fi

else
  echo "${blue}transmission container not running${reset}" && echo
  exit 0
fi
