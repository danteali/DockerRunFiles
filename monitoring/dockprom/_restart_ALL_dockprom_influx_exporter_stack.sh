#!/bin/bash

/home/ryan/scripts/docker/monitoring/dockprom/dockprom.start
/home/ryan/scripts/docker/monitoring/dockprom/influxdb_stack/influx_stack.start
/home/ryan/scripts/docker/monitoring/dockprom/exporters/restart_all_exporters.sh
