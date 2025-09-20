#!/bin/bash

# Get sensitive info from .conf file
CONF_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
typeset -A secrets    # Define array to hold variables 
while read line; do
  if echo $line | grep -F = &>/dev/null; then
    varname=$(echo "$line" | cut -d '=' -f 1); secrets[$varname]=$(echo "$line" | cut -d '=' -f 2-)
  fi
done < $CONF_DIR/dockprom.conf
#echo ${secrets[USERNAME]}; echo ${secrets[PASSWORD]}
USERNAME="${secrets[USERNAME]}"
PASSWORD="${secrets[PASSWORD]}"

docker stop nodeexporter
docker rm -f -v nodeexporter

ADMIN_USER=$USERNAME ADMIN_PASSWORD=$PASSWORD docker-compose -f /storage/Docker/dockprom/docker-compose.yml up -d --force-recreate nodeexporter
