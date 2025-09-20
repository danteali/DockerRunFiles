#!/bin/bash

# Get sensitive info from .conf file
CONF_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
typeset -A secrets    # Define array to hold variables 
while read line; do
  if echo $line | grep -F = &>/dev/null; then
    varname=$(echo "$line" | cut -d '=' -f 1); secrets[$varname]=$(echo "$line" | cut -d '=' -f 2-)
  fi
done < $CONF_DIR/radarr.conf
#echo ${secrets[FQDN]}; echo ${secrets[APIKEY]}

FQDN="${secrets[FQDN]}"

# Need to run where port is available so run against URL exposed via Traefik.
URL="https://radarr.$FQDN"

# Or we can use localhost and copy script to the config volume mounted in container then run with:
# docker exec sonarr /config/sonarr_get_seriesid.sh
#URL='http://localhost:8989'

APIKEY="${secrets[APIKEY]}"

echo "Triggering Radarr search for all missing movies via Radarr API..."

curl \
  -d '{name: "missingMoviesSearch", filterKey: "status", filterValue: "released"}' \
  -H "Content-Type: application/json" -X POST \
  $URL/api/command?apikey=$APIKEY
