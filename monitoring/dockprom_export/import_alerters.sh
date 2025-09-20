#!/bin/bash

#dashboards/datasources can be auto imported to grafana by putting the exported files in the relevant directories in /storage/Docker/dockprom/grafana
#but the alerting sources can't be so this script will do that if needed.

# To quickly import one file manually if we don't want to automatically pull in whole directory we can use command below.
# Note the parentheses around whole thing which allows us to set the USER/PASS as temp local variables and not permanent envvars
# We need to use variables for USER/PASS since PASS has complex chars and will mess up command if bare string used in command.
# ...
#(FILE='Slack.json'; \
#  USERNAME="<USERNAME>"; PASSWORD="<PASSWORD>"; IP="<IP_ADDRESS"> PORT=<PORT>; \
#  HOST="http://$USERNAME:$PASSWORD@$IP:$PORT"; \
#  curl -k -X POST -H "Content-Type: application/json" -H "Accept: application/json" --data-binary @$FILE "$HOST/api/alert-notifications" )
# ...
# Or after we removed complex chars from PASS for other reasons we can use:
#curl -k -X POST -H "Content-Type: application/json" -H "Accept: application/json" --data-binary @Slack.json "$HOST/api/alert-notifications"


## Get sensitive info from .conf file
CONF_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
typeset -A secrets    # Define array to hold variables 
while read line; do
  if echo $line | grep -F = &>/dev/null; then
    varname=$(echo "$line" | cut -d '=' -f 1); secrets[$varname]=$(echo "$line" | cut -d '=' -f 2-)
  fi
done < $CONF_DIR/exporter.conf
#echo ${secrets[USERNAME]}; echo ${secrets[PASSWORD]}; echo ${secrets[IP]}; echo ${secrets[PORT]}

## Variables
SCRIPT_DIR=$(dirname "$0")
DIR_DATA=$SCRIPT_DIR/grafana_exports/alert-notifications
USERNAME="${secrets[USERNAME]}"
PASSWORD="${secrets[PASSWORD]}"
IP="${secrets[IP]}"
PORT=${secrets[PORT]}
HOST="http://$USERNAME:$PASSWORD@$IP:$PORT"

for file in $DIR_DATA/*; do
    curl -k -X POST -H "Content-Type: application/json" -H "Accept: application/json" --data-binary @$file "${HOST}/api/alert-notifications"
done

echo
