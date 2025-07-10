#!/bin/bash

BACKUPMOUNTPOINT="/mnt/backup" # Enty must exist in fstab
SOURCEDIR="/mnt/backup/backup-data" # The directory that contains the files that we want to backup
TRANSFERUSER="offsite-backup" # User used to connect to the remote host - You must set up key based SSH authentication for this user
REMOTEHOST="" # Remote (offsite) host where to transfer the data to
REMOTEDESTINATIONDIR="/mnt/data/offsite-backups/$HOSTNAME" # Directory on the remote host where to put the data on

# Mount backup volume
mount $BACKUPMOUNTPOINT
# Check if backup volume is mounted (space after it prevents false positives with mountpoints that contains the same string)
if grep -qs "$BACKUPMOUNTPOINT " /proc/mounts; then
    # Check if SOURCEDIR exists
    if [ -d "$SOURCEDIR" ]; then
	# Transfer data to the remote machine using rsync (ssh)
	# Preserves file permissions, ownership and attributes
	# Uses zstd (multi-threaded) compression
	# Compares files and only transfers the differences (based on filename and time)
	# Deletes files on the destination that does not exist on the source directory
	# Handles sparse-files efficiently
        # Transfer speed is limited to 20.000Kbps
        rsync -aAXHSv --checksum --delete-during --compress --compress-choice=zstd --bwlimit=20000 $SOURCEDIR $TRANSFERUSER@$REMOTEHOST:$REMOTEDESTINATIONDIR

        echo "Script finished"
    else
        echo "'${SOURCEDIR}' does not exist!"
    fi
else
    echo "Failed to mount '$BACKUPMOUNTPOINT'!"
fi
