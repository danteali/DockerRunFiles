#!/bin/bash

# Check running as root - needed for logrotation
    if [ $(id -u) -ne 0 ]; then tput setaf 1; echo "Not running as root, attempting to automatically restart script with root access..."; tput sgr0; echo; sudo $0 $*; exit 1; fi

# (Re-)Install latest HACS
    /home/ryan/scripts/docker/monitoring/homeassistant/update_hacs.sh

# Rotate log as it makes it easier to analyse log file at /var/log/homeassistant/ instead of using dlog home-assistant
    echo
    echo "Rotating HA logs..."
    sudo logrotate -vf /etc/logrotate.d/homeassistant

# Get sensitive info from .conf file
CONF_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
typeset -A secrets    # Define array to hold variables 
while read line; do
  if echo $line | grep -F = &>/dev/null; then
    varname=$(echo "$line" | cut -d '=' -f 1); secrets[$varname]=$(echo "$line" | cut -d '=' -f 2-)
  fi
done < $CONF_DIR/reload.conf
#echo ${secrets[HOST]}; echo ${secrets[REST_API]}

HOST="${secrets[HOST]}"
REST_API=${secrets[REST_API]}

# Call HA restart service
    echo
    echo "Making HA restart service call..."
    curl -X POST -H "Authorization: Bearer $REST_API" -H "Content-Type: application/json" $HOST/api/services/homeassistant/restart

echo
