#!/bin/bash

BACKUPTIME="$(date +%F_%H-%M)" # Get current date and time
BACKUPLABEL="vh-root-$BACKUPTIME"
SOURCEDIR="/" # The directory that contains the files that we want to backup (in this case the entire system, but there are important exclusions below)
DESTINATIONDIR="/mnt/backup1/backup-data/bsdtar/root/weekly" # Root dir of all backups
DESTINATIONSUBDIR="$DESTINATIONDIR/$(date +%Y-%V)" # Weekly sub dir (full backup)

# Check if SOURCEDIR exists
if [ -d "$SOURCEDIR" ]; then
    # Create destination sub dir if it not exists
    mkdir -p "$DESTINATIONSUBDIR"

    # Create archive using bsdtar (only root file system and no other file systems like /mnt or /media)
    # bsdtar is able to preserve extended attributes and handles sparse files more efficient
    # Also exlude .qcow and .img files as well as /swapfile
    bsdtar --exclude="*.qcow2" --exclude="*.img" --exclude="/swapfile" --one-file-system --read-sparse --acls --xattrs -cpzvf "$DESTINATIONSUBDIR/$BACKUPLABEL.tar.gz" "$SOURCEDIR"

    # If exit status 0...
    if [ $? -eq 0 ]; then
        # ...then delete sub dirs older than 14 days
        find "$DESTINATIONDIR" -type d -mtime +14 -exec rm -r {} \;
    fi
    
    echo "Script finished"
else
    echo "'${SOURCEDIR}' does not exist!"
fi
