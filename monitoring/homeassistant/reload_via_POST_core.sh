#!/bin/bash

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

# Update config files, check config, push to github
    /home/ryan/scripts/docker/monitoring/homeassistant/3_update_ha_config_check_git.sh

curl -X POST -H "Authorization: Bearer $REST_API" -H "Content-Type: application/json"  $HOST/api/services/homeassistant/reload_core_config

echo