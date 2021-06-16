#!/bin/bash

/home/ryan/scripts/docker/monitoring/homeassistant/eclipse-mosquitto.start
/home/ryan/scripts/docker/monitoring/homeassistant/zigbee2mqtt.start
/home/ryan/scripts/docker/monitoring/homeassistant/node-red.start
/home/ryan/scripts/docker/monitoring/homeassistant/4_update_ha_config_check_git_restart_container.sh
