#!/bin/bash

# Get sensitive info from .conf file
CONF_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
typeset -A secrets    # Define array to hold variables 
while read line; do
  if echo $line | grep -F = &>/dev/null; then
    varname=$(echo "$line" | cut -d '=' -f 1); secrets[$varname]=$(echo "$line" | cut -d '=' -f 2-)
  fi
done < $CONF_DIR/sonarr.conf
#echo ${secrets[FQDN]}; echo ${secrets[APIKEY]}

FQDN="${secrets[FQDN]}"

# Need to run where port is available so run against URL exposed via Traefik.
URL="https://sonarr.$FQDN"

# Or we can use localhost and copy script to the config volume mounted in container then run with:
# docker exec sonarr /config/sonarr_get_seriesid.sh
#URL='http://localhost:8989'

# Get API key from Sonarr
APIKEY="${secrets[APIKEY]}"

echo "Triggering Sonarr search for all missing episodes via Sonarr API..."

curl $URL/api/command -X POST \
  --header "Content-Type: Application/JSON" \
  --header "X-Api-Key:$APIKEY" \
  --data '{"name": "missingepisodesearch"}'
