#!/bin/bash

# This script quickly deletes content from a git repo if you accidentally
# pushed sensitive info e.g. passwords.
# Pass a filename to this script and it will delete the file from github including
# the file's change history.

# To use:
# 1. Make sure the file still exists in the local directory
# 2. Edit the file to remove any compromising info.
# 3. Pass the filename (plus relative path if needed) as argument to this script
#    e.g. ./_delete_git_history.sh monitoring/portainer.start

# You should really consider any sensitive info pushed to github to be 
# compromised but this script will delete it from github anyway 

FILE=$1

cp $1 /tmp/$FILE

git filter-branch --force --index-filter "git rm --cached --ignore-unmatch $FILE" --prune-empty --tag-name-filter cat -- --all
git push origin --force --all
mv /tmp/$FILE $1