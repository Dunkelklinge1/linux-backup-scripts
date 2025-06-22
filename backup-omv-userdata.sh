#!/bin/bash

BACKUPMOUNTPOINT="/mnt/backup" # Enty must exist in fstab
BACKUPTIME="$(date +%F_%H-%M)" # Get current date and time in format YYYY-mm-DD_HH-MM
BACKUPLABEL="mnt-data-$BACKUPTIME"
SOURCEDIR="/srv/dev-disk-by-uuid-XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX/shares" # The directory that contains the files that we want to backup
DESTINATIONDIR="/mnt/backup/backup-data/borg" # Root dir of all backups and thus our Borg repository

# Check if SOURCEDIR exists
if [ -d "$SOURCEDIR" ]; then
    # Mount backup volume
    mount $BACKUPMOUNTPOINT
    # Check if backup volume is mounted (space after it prevents false positives with mountpoints that contains the same string)
    if grep -qs "$BACKUPMOUNTPOINT " /proc/mounts; then
        # Create the destination dir
        mkdir -p $DESTINATIONDIR
        # Create the Borg repo if there is none
        borg init --encryption=none $DESTINATIONDIR
        # Create the incremental archive using Borg (only selected file system and no other ones even if mounted)
        borg create --stats --progress --one-file-system --compression=zstd,5 $DESTINATIONDIR::$BACKUPLABEL $SOURCEDIR
        # Keep only backups within 14 days and last 4 weekly (sunday) ones
        borg prune -v --list --keep-within=14d --keep-weekly=4 $DESTINATIONDIR
        # Free up disk space
        borg compact $DESTINATIONDIR

        echo "Script finished"
    else
        echo "Failed to mount '$BACKUPMOUNTPOINT'!"
    fi
else
    echo "'${SOURCEDIR}' does not exist!"
fi
