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

curl -X POST -H "Authorization: Bearer $REST_API" -H "Content-Type: application/json"  $HOST/api/services/automation/reload

echo


#source: https://community.home-assistant.io/t/i-made-a-script-that-automatically-updates-homeassistant-when-i-change-my-yaml-files/18937

# Could set up full auto-reload using inotify, our yaml copy script, and this script:
#inotifywait -m /home/homeassistant/.homeassistant/ -e close_write |
#while read path action file; do
#    if [[ "$file" == "automations.yaml" ]]; then
#        echo "$file"
#        curl -X POST -H "x-ha-access: yourpass" -H "Content-Type: application/json" http://hassbian.local:8123/api/services/automation/reload
#    fi
#    if [[ "$file" == "groups.yaml" ]]; then
#        echo "$file"
#        curl -X POST -H "x-ha-access: yourpass" -H "Content-Type: application/json" http://hassbian.local:8123/api/services/group/reload
#    fi
#    if [[ "$file" == "core.yaml" ]]; then
#        echo "$file"
#        curl -X POST -H "x-ha-access: yourpass" -H "Content-Type: application/json" http://hassbian.local:8123/api/services/homeassistant/reload_core_config
#    fi
#done