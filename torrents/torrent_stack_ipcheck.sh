#!/bin/bash

## Script ot check IP addresses of running torrent containers

blue=`tput setaf 4`
red=`tput setaf 1`
green=`tput setaf 2`
yellow=`tput setaf 3`
txtund=`tput sgr 0 1`          # Underline
txtbld=`tput bold`             # Bold
reset=`tput sgr0`

SOURCE="/home/ryan/scripts/docker/torrents"

echo ${red} && echo "================ ${txtund}Checking torrent container IP Addresses${reset}${red} ==================="
echo ${reset}


curl -s ipinfo.io > $SOURCE/ipcheck_isp.log
ISPIP=`cat $SOURCE/isp_ip.tmp | grep -e \"ip | tr -d '\n\r ,"ip:'`
ISPCO=`cat $SOURCE/isp_ip.tmp | grep -e country | tr -d '", ' | sed 's/country://'`
rm $SOURCE/ipcheck_isp.log
echo "ISP IP Address: ${green}$ISPIP${reset}"
echo "ISP Country: ${green}$ISPCO${reset}"
echo "" && echo "--------------------------------------" && echo

if [ ! -z "$(docker ps | grep vpn-torr | grep Up)" ]; then
  docker run --rm --net=container:vpn-torr appropriate/curl curl -s ipinfo.io > $SOURCE/ipcheck_vpn.log
  PIAIP=`cat $SOURCE/pia_ip.tmp | grep -e \"ip | tr -d '\n\r ,"ip:'`
  PIACO=`cat $SOURCE/pia_ip.tmp | grep -e country | tr -d '", ' | sed 's/country://'`
  rm $SOURCE/ipcheck_vpn.log
  echo "PIA IP Address: ${green}$PIAIP${reset}"
  echo "PIA Country: ${green}$PIACO${reset}"
  echo "" && echo "--------------------------------------" && echo
else
  echo "${red}PIA container not running${reset}"
  echo "" && echo "--------------------------------------" && echo
fi

if [ ! -z "$(docker ps | grep transmission | grep Up)" ]; then
  docker run --rm --net=container:transmission appropriate/curl curl -s ipinfo.io > $SOURCE/ipcheck_trans.log
  TRANSIP=`cat $SOURCE/trans_ip.tmp | grep -e \"ip | tr -d '\n\r ,"ip:'`
  TRANSCO=`cat $SOURCE/trans_ip.tmp | grep -e country | tr -d '", ' | sed 's/country://'`
  rm $SOURCE/ipcheck_trans.log
  echo "Transmission IP Address: ${green}$TRANSIP${reset}"
  echo "Transmission Country: ${green}$TRANSCO${reset}"
  echo "" && echo "--------------------------------------" && echo
else
  echo "${red}Transmission container not running${reset}"
  echo "" && echo "--------------------------------------" && echo
fi

if [ ! -z "$(docker ps | grep sonarr | grep Up)" ]; then
  docker run --rm --net=container:sonarr appropriate/curl curl -s ipinfo.io > $SOURCE/ipcheck_sonarr.log
  SONIP=`cat $SOURCE/sonarr_ip.tmp | grep -e \"ip | tr -d '\n\r ,"ip:'`
  SONCO=`cat $SOURCE/sonarr_ip.tmp | grep -e country | tr -d '", ' | sed 's/country://'`
  rm $SOURCE/ipcheck_sonarr.log
  echo "Sonarr IP Address: ${green}$SONIP${reset}"
  echo "Sonarr Country: ${green}$SONCO${reset}"
  echo "" && echo "--------------------------------------" && echo
else
  echo "${red}Sonarr container not running${reset}"
  echo "" && echo "--------------------------------------" && echo
fi

if [ ! -z "$(docker ps | grep radarr | grep Up)" ]; then
  docker run --rm --net=container:radarr appropriate/curl curl -s ipinfo.io > $SOURCE/ipcheck_radarr.log
  RADIP=`cat $SOURCE/radarr_ip.tmp | grep -e \"ip | tr -d '\n\r ,"ip:'`
  RADCO=`cat $SOURCE/radarr_ip.tmp | grep -e country | tr -d '", ' | sed 's/country://'`
  rm $SOURCE/ipcheck_radarr.log
  echo "Radarr IP Address: ${green}$RADIP${reset}"
  echo "Radarr Country: ${green}$RADCO${reset}"
  echo "" && echo "--------------------------------------" && echo
else
  echo "${red}Radarr container not running${reset}"
  echo "" && echo "--------------------------------------" && echo
fi

if [ ! -z "$(docker ps | grep jackett | grep Up)" ]; then
  docker run --rm --net=container:jackett appropriate/curl curl -s ipinfo.io > $SOURCE/ipcheck_jackett.log
  JACKIP=`cat $SOURCE/jackett_ip.tmp | grep -e \"ip | tr -d '\n\r ,"ip:'`
  JACKCO=`cat $SOURCE/jackett_ip.tmp | grep -e country | tr -d '", ' | sed 's/country://'`
  rm $SOURCE/ipcheck_jackett.log
  echo "Jackett IP Address: ${green}$JACKIP${reset}"
  echo "Jackett Country: ${green}$JACKCO${reset}"
  echo "" && echo "--------------------------------------" && echo
else
  echo "${red}Radarr container not running${reset}"
  echo "" && echo "--------------------------------------" && echo
fi

