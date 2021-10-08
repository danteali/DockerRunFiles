#!/bin/sh

# https://www.robustperception.io/monitoring-directory-sizes-with-the-textfile-collector

# Specify where output file should be saved. This should be where nodeexporter looks for the files.
OUTPUTFILE=/storage/Docker/nodeexporter/textfile_collector/directory_size.prom

# Add list of directories to be monitored. 
DIRECTORIES="/storage/Media/Audio
             /storage/Media/Books
             /storage/Media/Comics
             /storage/Media/Video/Movies*
             /storage/Media/Video/Misc
             /storage/Media/Video/TV
             /storage/scratchpad
             /storage/Backup
             /storage/Docker
             /home/ryan"

du -sb $DIRECTORIES \
    | sed -ne 's/^\([0-9]\+\)\t\(.*\)$/node_directory_size_bytes{directory="\2"} \1/p' > $OUTPUTFILE.$$ && \
    mv $OUTPUTFILE.$$ $OUTPUTFILE
