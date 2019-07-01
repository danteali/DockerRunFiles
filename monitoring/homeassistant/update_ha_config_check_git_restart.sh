#!/bin/bash

# Update config files, check config, push to github
    /home/ryan/scripts/docker/monitoring/homeassistant/update_ha_config_check_git.sh

# Restart HA
    /home/ryan/scripts/docker/monitoring/homeassistant/restart_homeassistant.sh

# Restart node red
    #/home/ryan/scripts/docker/monitoring/homeassistant/node-red.start


echo