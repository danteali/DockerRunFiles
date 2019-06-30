#!/bin/bash

## Run backups to ACD encrypted volumes
red=`tput setaf 1`
green=`tput setaf 2`
yellow=`tput setaf 3`
blue=`tput setaf 4`
reset=`tput sgr0`

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
DIR_EXPORT=$SCRIPT_DIR/grafana_exports
DIR_ARCHIVE=$SCRIPT_DIR/archive
FILENAME=$(date '+%Y%m%d-%H%M%S')
FILE_ARCHIVE=$DIR_ARCHIVE/$FILENAME.zip
USERNAME="${secrets[USERNAME]}"
PASSWORD="${secrets[PASSWORD]}"
IP="${secrets[IP]}"
PORT=${secrets[PORT]}
HOST="http://$USERNAME:$PASSWORD@$IP:$PORT"

## Info / Help
echo
  echo "${yellow}====================================================================================================${reset}"
  echo "${red}       Extract and save backups of Grafana dashboards, datasources, and alerters${reset}"
  echo "${yellow}----------------------------------------------------------------------------------------------------${reset}"
  echo "${green}Tool will extract current set of Grafana dashboards, datasources, and alerters."
  echo "These will be saved in (destination defined in script)...${blue}"
  echo "$DIR_EXPORT"
  echo "${green}Existing backups in this destination will be deleted."
  echo "${yellow}---------------------${reset}"
  echo "${green}An archive of these extracted files will be saved in (destination defined in script)...${blue}"
  echo "$FILE_ARCHIVE"
  echo "${yellow}---------------------${reset}"
  echo "${green}Note that contents of zip file can be viewed without extracting with...${blue}"
  echo "unzip -l $FILE_ARCHIVE"
  echo "${green}And individual files can be extracted with...${blue}"
  echo "unzip -j $FILE_ARCHIVE dir/in/archive/file.txt -d /path/to/unzip/to"
  echo "${yellow}====================================================================================================${reset}"
echo && echo

# Delete existing extracts
rm -rf $DIR_EXPORT/*


#curl arguements:
#-f = --fail = Fail silently (no output at all) on server errors
#-s = --silent = Don't show progress meter or error messages
#-L = --location = If the server reports that the requested page has moved to a different location (indicated with a Location: header and a 3XX response code), this option will make curl redo the request on the new place.
#-S = --show-error = When used with -s, --silent, it makes curl show an error message if it fails.
#-k = --insecure = By default, every SSL connection curl makes is verified to be secure. This option allows curl to proceed and operate even for server connections otherwise considered insecure.


fetch_fields() {
    curl -sSL -f -k "${HOST}/api/${1}" | jq -r "if type==\"array\" then .[] else . end| .${2}"
}



#MAKE DIRS IF MISSING
# We will archive exports by moving the whole set of destination dirs so let's re-create if they are missing
mkdir -p $DIR_EXPORT/{alert-notifications,dashboards,dashboards_raw,datasources}
mkdir -p $DIR_EXPORT/_defaults/{dashboards,datasources}

# DASHBOARDS
DIR_DASH="$DIR_EXPORT/dashboards"
DIR_DASHRAW="$DIR_EXPORT/dashboards_raw"
DIR_DASH_DEFAULT="$DIR_EXPORT/_defaults/dashboards"
echo "" && echo "Exporting dashboards ..."
    for dash in $(fetch_fields 'search?query=&' 'uri'); do
        DB=$(echo ${dash}|sed 's,db/,,g')
        echo "   ... $DB"
        curl -sSL -f -k "${HOST}/api/dashboards/${dash}" | jq 'del(.overwrite,.dashboard.version,.meta.created,.meta.createdBy,.meta.updated,.meta.updatedBy,.meta.expires,.meta.version)' > "$DIR_DASHRAW/$DB.json"
    done
# We can save built in dashboards in separate directory so not re-imported: docker-containers.json, docker-host.json, monitor-services.json, nginx.json
echo "" && echo "Checking for default dashboards ..."
    for file in $DIR_DASHRAW/*; do
        # Changed script to only do this with Nginx since I've customised the others so we want them in the set of saved exports to allow import script to find them later.
        #if [ $(basename -- "${file}") == "docker-containers.json" ] || [ $(basename -- "${file}") == "docker-host.json" ] || [ $(basename -- "${file}") == "monitor-services.json" ] || [ $(basename -- "${file}") == "nginx.json" ]; then
        if [ $(basename -- "${file}") == "nginx.json" ]; then
            echo "   ... moving $(basename -- "${file}") to $DIR_DASH_DEFAULT"
            mv ${file} $DIR_DASH_DEFAULT/$(basename -- "${file}")
        fi
    done
echo
# Strip first 'id' line to enable import without error
echo "" && echo "Processing file(s) to enable dashboard import ..."
    for file in $DIR_DASHRAW/*; do
        echo "   ... $(basename -- "${file}")"
        sed '0,/"id"/{/"id"/d;}' ${file} > $DIR_DASH/$(basename -- "${file}")
    done
echo


# DATASOURCES
DIR_DATA="$DIR_EXPORT/datasources"
DIR_DATA_DEFAULT="$DIR_EXPORT/_defaults/datasources"
echo "Exporting datasources ..."
    for id in $(fetch_fields 'datasources' 'id'); do
        DS=$(echo $(fetch_fields "datasources/${id}" 'name')|sed 's/ /-/g')
        echo "   ... $DS"
        curl -sSL -f -k "${HOST}/api/datasources/${id}" | jq '' > "$DIR_DATA/${DS}.json"
    done
# Save built in datasources in separate directory so not re-imported: Prometheus.json
echo "Checking for default datasources ..."
    for file in $DIR_DATA/*; do
        if [ $(basename -- "${file}") == "Prometheus.json" ]; then
            echo "   ... moving $(basename -- ${file}) to $DIR_DATA_DEFAULT"
            mv $file $DIR_DATA_DEFAULT/$(basename -- ${file})
        fi
    done
echo


# ALERTERS
DIR_ALERT="$DIR_EXPORT/alert-notifications"
echo "Exporting alerters ..."
    for id in $(fetch_fields 'alert-notifications' 'id'); do
        curl -sS -f -k "${HOST}/api/alert-notifications/${id}" | jq 'del(.created,.updated)' > "$DIR_ALERT/${id}.json"
        NEWNAME=$(cat "$DIR_ALERT/${id}.json" | grep name | sed -e 's/  "name": "\(.*\)",/\1/')
        echo "   ... $NEWNAME"
        #mv "$DIR_ALERT/${id}.json" "$DIR_ALERT/$NEWNAME.json"
    done
echo

# Zip extract for archiving
echo "Creating zip archive ..."
zip -r $FILE_ARCHIVE $DIR_EXPORT
