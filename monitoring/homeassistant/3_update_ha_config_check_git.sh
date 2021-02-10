#!/bin/bash

# Do #2 first (which in trun does #1), then additional commands.

# ============================================================================================
# Exit on any failed commands - will exit script if any command fails 
# i.e. won't try to push to git push if config check fails.
    set -e
# keep track of the last executed command
    trap 'last_command=$current_command; current_command=$BASH_COMMAND' DEBUG
# echo an error message before exiting
    trap 'echo "\"${last_command}\" command failed with exit code $?."' EXIT
# ============================================================================================

# Update config files, check config, push to github
    /home/ryan/scripts/docker/monitoring/homeassistant/2_update_ha_config_check.sh

# Push to github if no errors in config check
    echo
    echo "Pushing changed files to github..."
    /home/ryan/scripts/docker/monitoring/homeassistant/github_update.sh
    
echo


# Other version of error checking:
#
#exit_on_error() {
#    exit_code=$1
#    last_command=${@:2}
#    if [ $exit_code -ne 0 ]; then
#        >&2 echo "\"${last_command}\" command failed with exit code ${exit_code}."
#        exit $exit_code
#    fi
#}        
### enable !! command completion
#set -o history -o histexpand
#
