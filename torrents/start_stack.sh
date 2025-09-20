#!/bin/bash

blue=`tput setaf 4`
red=`tput setaf 1`
green=`tput setaf 2`
yellow=`tput setaf 3`
txtund=`tput sgr 0 1`          # Underline
reset=`tput sgr0`

SOURCE="/home/ryan/scripts/docker/torrents"
IPCHECK="/home/ryan/scripts/docker/torrents/ipcheck_vpn.log"
ISPIP=`curl -s ipinfo.io | grep -e ip | tr -d '\n\r ,"ip:'`
VPNCONNECTED=0

echo ${red} && echo "================ ${txtund}Stopping any torrent containers${reset}${red} ==================="
echo ${reset}
docker stop torrentproxy
docker stop desktop
docker stop sabnzbd
docker stop lazylibrarian
docker stop jackett
docker stop couchpotato
docker stop bazarr
docker stop radarr
docker stop sonarr
docker stop transmission
docker stop vpn-torr
docker stop dockprom-transmission-exporter

docker rm -f -v torrentproxy
docker rm -f -v desktop
docker rm -f -v sabnzbd
docker rm -f -v lazylibrarian
docker rm -f -v jackett
docker rm -f -v couchpotato
docker rm -f -v bazarr
docker rm -f -v radarr
docker rm -f -v sonarr
docker rm -f -v transmission
docker rm -f -v vpn-torr
docker rm -f -v dockprom-transmission-exporter

echo ${green} && echo "================== ${txtund}Starting torrent containers${reset}${green} ==================="

echo ${blue}
echo "---------------------------- PIA -------------------------------"
echo ${yellow}

$SOURCE/vpn-torr.start --nochecks
echo ${reset}

while [[ $VPNCONNECTED == 0 ]]
do
  docker run --rm --net=container:vpn-torr appropriate/curl curl -s ipinfo.io > $IPCHECK
  PIAIP=`cat $IPCHECK | grep -e \"ip | tr -d '\n\r ,"ip:'`
  PIACO=`cat $IPCHECK | grep -e country | tr -d '", ' | sed 's/country://'`

  if [[ $PIACO == *"ES"* ]] || [[ $PIACO == *"RO"* ]] || [[ $PIACO == *"TR"* ]] || [[ $PIACO == *"BR"* ]] || [[ $PIACO == *"NO"* ]]; then
    VPNCONNECTED=1
    echo ${green}
    echo "VPN Connected on IP: $PIAIP"
    echo "VPN Country: $PIACO"
    echo "Continuing with service startup...${reset}"
  else
    VPNCOUNT=$((VPNCOUNT+1))
    echo "${reset}# of VPN checks: $VPNCOUNT"
    echo "PIA IP Address: $PIAIP"
    echo "PIA Country: $PIACO"
    echo "----------------------------"
    sleep 5
  fi

  if [[ $VPNCOUNT == 10 ]]; then
    echo "${red}VPN not connected, exiting startup script."
    echo "Killing PIA container...${reset}"
    docker stop vpn-torr
    docker rm -f -v vpn-torr
    exit 1
  fi
done

echo ${blue}
echo "----------------------- transmission ---------------------------"
echo ${yellow}
$SOURCE/transmission.start --nochecks
echo ${reset}

echo ${blue}
echo "-------------------------- jackett -----------------------------"
echo ${yellow}
$SOURCE/jackett.start --nochecks
echo ${reset}

echo ${blue}
echo "--------------------------- sonarr -----------------------------"
echo ${yellow}
$SOURCE/sonarr.start --nochecks
echo ${reset}

echo ${blue}
echo "-------------------------- radarr ------------------------------"
echo ${yellow}
$SOURCE/radarr.start --nochecks
echo ${reset}

echo ${blue}
echo "-------------------------- bazarr ------------------------------"
echo ${yellow}
$SOURCE/bazarr.start --nochecks
echo ${reset}

#echo ${blue}
#echo "---------------------- LazyLibrarian ---------------------------"
#echo ${yellow}
#$SOURCE/lazylibrarian.start --nochecks
#echo ${reset}

#echo ${blue}
#echo "------------------------ couchpotato ---------------------------"
#echo ${yellow}
#$SOURCE/couchpotato.start --nochecks
#echo ${reset}

#echo ${blue}
#echo "------------------------- sabnzbd ------------------------------"
#echo ${yellow}
#$SOURCE/sabnzbd.start --nochecks
#echo ${reset}

#echo ${blue}
#echo "-------------------------- desktop ------------------------------"
#echo ${yellow}
#$SOURCE/desktop.start
#echo ${reset}

#echo ${blue}
#echo "----------------- torrent services nginx proxy -----------------"
#echo ${yellow}
#$SOURCE/torrentproxy.start
#echo ${reset}

echo ${green}
echo "===================== sending notifications ===================="
echo ${yellow}
#pushbullet "Torrent Services Started" "`date`"
pushover -c "media_stack" -T "Torrent Services Started" -m "`date`"
slack -u torrent_stack -c "#media_stack" -t "Torrent Stack (Re)Started" -e :arrow_double_down:
echo ${reset}
