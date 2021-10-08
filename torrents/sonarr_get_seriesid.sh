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

# Note: We can extract all series details with:
# curl -s $URL/api/series --header "X-Api-Key: $APIKEY" --compressed > sonarr.txt
# And do manual searching with:
# cat sonarr.txt | jq -rs ".[]| .[] | select(.title==\"$SERIES\") | .id "

# Pass string as argument to make more automated rather than setting variable below.
if [[ $# -eq 0 ]] ; then
  echo "Pass series name as argument e.g. ./sonarr_get_seriesid.sh 'Five Came Back' "
  exit 1
fi
SERIES=$1
echo "Searching for seriesID of: $SERIES"

SERIESID=$(curl -s $URL/api/series --header "X-Api-Key: $APIKEY" --compressed |  jq -rs ".[]| .[] | select(.title==\"$SERIES\") | .id ")

if [[ ! -z $SERIESID ]]; then  #Tests if length of string is zero
  echo "SeriesID is: $SERIESID"
else
  echo "No series called found called: $SERIES"
fi