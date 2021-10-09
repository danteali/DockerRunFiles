#!/bin/bash

/home/ryan/scripts/docker/monitoring/dockprom/exporters/exporter_pihole.start
/home/ryan/scripts/docker/monitoring/dockprom/exporters/varken.start
/home/ryan/scripts/docker/monitoring/dockprom/exporters/exporter_speedtest.start
/home/ryan/scripts/docker/monitoring/dockprom/exporters/exporter_transmission.start 