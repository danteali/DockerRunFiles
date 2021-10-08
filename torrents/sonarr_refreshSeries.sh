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


# Example series IDs for testing:
    # Five Came Back = 4
    # Friends = 108
    # Fargo = 15

# Text colour variables
red=`tput setaf 1`
green=`tput setaf 2`
yellow=`tput setaf 3`
blue=`tput setaf 4`
reset=`tput sgr0`

# Variable to check for number argument later
isnum='^[0-9]+$'

echo
echo "${red}============================================================================================================================${reset}"
echo "${red}SONARR - RefreshSeries   ${reset}"
echo "${red}============================================================================================================================${reset}"
echo "${blue}Script to refresh series info from Trakt (i.e. identify if new episodes/seasons available), rescan disk for series files, ${reset}"
echo "${blue}and trigger search for missing shows.${reset}"
echo "${red}----------------------------------------------------------------------------------------------------------------------------${reset}"
echo "${green}Supply seriesID # as argument to refresh specific series (seriesID can be found with torr_sonarr_get_seriesid.sh script). ${reset}"
echo "${green}e.g. to refresh Friends:  ./torr_sonarr_refreshSeries.sh 108${reset}"
echo "${red}---${reset}"
echo "${green}Or supply series name as argument (must be in single quotes to account for any spaces). ${reset}"
echo "${green}e.g. to refresh Five Came Back:  ./torr_sonarr_refreshSeries.sh 'Five Came Back'${reset}"
echo "${red}---${reset}"
echo "${green}Run without argument to update ALL series.${reset}"
echo "${red}---${reset}"
echo "${green}Run with argument '--all' to update ALL series with no further interaction.${reset}"
echo "${red}============================================================================================================================${reset}"
echo
echo

###===================================###
### Auto refresh all - no interaction ###
###===================================###
if [[ $* == *"--all"* ]] ; then
# '--all' passed - assuming refresh all with no interaction
  echo "Refreshing ALL..."
    # Send RefershSeries API command
    curl $URL/api/command -X POST \
      --header "Content-Type: Application/JSON" \
      --header "X-Api-Key:$APIKEY" \
      --data '{"name": "refreshseries"}'

###===================###
### series ID handler ###
###===================###
elif [[ $1 =~ $isnum ]] ; then
# Number passed - assuming using seriesID
  SERIESID=$1
  read -p "Are you sure you want to refresh seriesID $SERIESID? [y/n]: " -n 1 -r
  echo    # (optional) move to a new line
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Refreshing seriesID $SERIESID..."
    # Send RefershSeries API command
    curl $URL/api/command -X POST \
      --header "Content-Type: Application/JSON" \
      --header "X-Api-Key:$APIKEY" \
      --data '{"name": "refreshseries", "seriesId": "'$SERIESID'"}'
  # Handle 'No' or invalid continue responses
  elif [[ $REPLY =~ ^[Nn]$ ]]; then
    exit 0
  else
    echo "Invalid choice. Exiting."
    exit 1
  fi

###====================###
### refresh ALL series ###
###====================###
elif [[ $# -eq 0 ]]; then
# No argument passed so updating all.
  read -p "Are you sure you want to refresh ALL series? [y/n]: " -n 1 -r
  echo    # (optional) move to a new line
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Refreshing ALL..."
    # Send RefershSeries API command
    curl $URL/api/command -X POST \
      --header "Content-Type: Application/JSON" \
      --header "X-Api-Key:$APIKEY" \
      --data '{"name": "refreshseries"}'
  # Handle 'No' or invalid continue responses
  elif [[ $REPLY =~ ^[Nn]$ ]]; then
    exit 0
  else
    echo "Invalid choice. Exiting."
    exit 1
  fi

###=====================###
### series NAME handler ###
###=====================###
else
# Not a number, not empty, so assume it's a series name
  SERIESNAME=$1
  read -p "Are you sure you want to refresh series named $SERIESNAME? [y/n]: " -n 1 -r
  echo    # (optional) move to a new line
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Getting series ID number..."
      # Get seriesID from Sonarr API
        SERIESID=$(curl -s $URL/api/series --header "X-Api-Key: $APIKEY" --compressed |  jq -rs ".[]| .[] | select(.title==\"$SERIESNAME\") | .id ")
      # Check for seriesID response
      if [[ ! -z $SERIESID ]]; then  #Tests if length of string is zero
        echo "SeriesID is: $SERIESID"
      else
        echo "No series called found called: $SERIESNAME"
        exit 1
      fi
    echo "Refreshing seriesID $SERIESID..."
      # Send RefershSeries API command
      curl $URL/api/command -X POST \
        --header "Content-Type: Application/JSON" \
        --header "X-Api-Key:$APIKEY" \
        --data '{"name": "refreshseries", "seriesId": "'$SERIESID'"}'
  # Handle 'No' or invalid continue responses
  elif [[ $REPLY =~ ^[Nn]$ ]]; then
    exit 0
  else
    echo "Invalid choice. Exiting."
    exit 1
  fi
fi