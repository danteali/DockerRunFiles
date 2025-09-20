#!/bin/bash

if [ $(id -u) -ne 0 ]; then tput setaf 1; echo "Not running as root, attempting to automatically restart script with root access..."; tput sgr0; echo; sudo $0 $*; exit 1; fi

# Backup PMS database

# Plex schedules a DB backup every couple of days and saves it in:
# /config/Library/Application Support/Plex Media Server/Plug-in Support/Databases
# We will backup this backup. And also backup the other plugin DB backups in this dir e.g. trakt

# Also need to backup preferences.xml

# To restore from DB backups:
# https://support.plex.tv/articles/202485658-restore-a-database-backed-up-via-scheduled-tasks/
#  1. Stop/quit your Plex Media Server
#  2. Move the following files out of the directory and store them somewhere for backup, just in case. (You don’t want the “-shm” and “-wal” files to remain in the databases directory.)
#     com.plexapp.plugins.library.db
#     com.plexapp.plugins.library.db-shm
#     com.plexapp.plugins.library.db-wal
#  3. Replace above files.Duplicate the database backup file into the correct directory and then rename it to com.plexapp.plugins.library.db
#  4. Ensure that Plex Media Server has read/write permissions to the restored database file (e.g. in a Linux install, the plex:plex (user:group) needs access)


DATETIME=$(date +%Y%m%d-%H%M%S)
DESTINATION="/storage/Backup/Current/Linux_Config_Files"
FILENAME="Plex_DB_and_Prefs.$DATETIME"
LOCATION_DB=/storage/Docker/plex/config/Library/Application\ Support/Plex\ Media\ Server/Plug-in\ Support/Databases
LOCATION_PREFS=/storage/Docker/plex/config/Library/Application\ Support/Plex\ Media\ Server/Plug-in\ Support/Preferences
LOCATION_PREFS_XML=/storage/Docker/plex/config/Library/Application\ Support/Plex\ Media\ Server/Preferences.xml
COPIES_TO_KEEP=2
#
COPIES_TO_KEEP_PLUSONE=$((COPIES_TO_KEEP+1))

# ======================
# CREATE ARCHIVE
# ======================

zip -vr $DESTINATION/$FILENAME.zip \
  "$LOCATION_DB"/*.db \
  "$LOCATION_DB"/*.db-shm \
  "$LOCATION_DB"/*.db-wal \
  "$LOCATION_PREFS_XML" \
  "$LOCATION_PREFS"

# ======================
# DELETE OLD ARCHIVE(S)
# ======================

# Sorts by alphanumeric so dated filenames important
echo; echo "Deleting old archives..."
ls -1 $DESTINATION/*.zip | sort -r | tail -n +$COPIES_TO_KEEP_PLUSONE | xargs rm > /dev/null 2>&1


# ======================
# PERMISSIONS
# ======================
echo; echo "Changing permissions..."
chmod 777 $DESTINATION/$FILENAME.zip
chown ryan:ryan $DESTINATION/$FILENAME.zip

echo
