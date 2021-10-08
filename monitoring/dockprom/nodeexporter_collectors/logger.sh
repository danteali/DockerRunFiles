#!/bin/sh

# Generate text file for node exporter collector to record generic activity.
# Call with arguments:
# $1 = metric suffix ie. will be appended to 'node_' to record in Prometheus
# $2 = storage
# $3= metric e.g. 1(start)/0(stop) or 3.14 or anything

# Make sure to output to the path where NodeExporter is configured to look for files.

# Example use:
# ./logger.sh "snapraid" "snapraid" "1"
# ./logger.sh "docker_nextcloud" "nextcloud" "running"

# Define variables
SUFFIX=$1
ACTION=$2
METRIC=$3

# Specify where output file should be saved.
OUTPUTFILE=/storage/Docker/nodeexporter/textfile_collector/$SUFFIX.prom

echo "node_$SUFFIX{action=\"$ACTION\"} $METRIC" > $OUTPUTFILE
