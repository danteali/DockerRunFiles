#!/bin/sh

# Generate text file for node exporter collector to record duplicacy activity.
# Call with arguments:
# $1 = action, $2 = storage, $3=1(start)/0(stop)

# Prometheus will import data and display in 'node_duplicacy' metric

# Specify where output file should be saved. This should be where nodeexporter looks for the files.
OUTPUTFILE=/storage/Docker/nodeexporter/textfile_collector/duplicacy.prom

# Define variables
ACTION=$1
STORAGE=$2
ONOFF=$3

echo "node_duplicacy{action=\"$ACTION\", storage=\"$STORAGE\"} $ONOFF" > $OUTPUTFILE
