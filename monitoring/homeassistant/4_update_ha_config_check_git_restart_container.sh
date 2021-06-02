#!/bin/bash

# Do #3 first (which in turn does #2, which does #1), then additional commands.

# Update config files, check config, push to github
    /home/ryan/scripts/docker/monitoring/homeassistant/3_update_ha_config_check_git.sh

# Restart HA
    # via POST - doesn't recreate container
    #/home/ryan/scripts/docker/monitoring/homeassistant/restart_homeassistant.sh
    # restart whole container
    /home/ryan/scripts/docker/monitoring/homeassistant/home-assistant.start

# Restart node red
    #/home/ryan/scripts/docker/monitoring/homeassistant/node-red.start


echo