#!/bin/bash

# Do #1 first, then additional commands.

# Update config files
    echo
    echo "Updating any changed .yaml files..."
    /home/ryan/scripts/docker/monitoring/homeassistant/1_update_ha_yamls.sh

# config check
    echo
    echo "Checking configuration..."
    docker exec -ti home-assistant python -m homeassistant --config /config --script check_config
