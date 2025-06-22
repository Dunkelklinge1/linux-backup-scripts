#!/bin/bash

BACKUPMOUNTPOINT="/mnt/backup" # Enty must exist in fstab
BACKUPTIME="$(date +%F_%H-%M)" # Get current date and time in format YYYY-mm-DD_HH-MM
BACKUPLABEL="matrix-synapse-database-$BACKUPTIME"
DESTINATIONDIR="/mnt/backup/backup-data/pg_dump" # Root dir of all backups
DBUSER="synapse" # DB user
DBNAME="synapse" # DB name

# Mount backup volume
mount $BACKUPMOUNTPOINT
# Check if backup volume is mounted (space after it prevents false positives with mountpoints that contains the same string)
if grep -qs "$BACKUPMOUNTPOINT " /proc/mounts; then
    # Create the destination dir
    mkdir -p $DESTINATIONDIR
    chown -R synapse:synapse $DESTINATIONDIR
    # Create database dump
    # Runs as synapse user as this user has the .pgpass credentials file in it's home directory
    sudo -u synapse pg_dump -h localhost -f "$DESTINATIONDIR/$BACKUPLABEL.pg_dump" --compress=9 -U $DBUSER $DBNAME
    # Delete dumps older than 60 days
    find "$DESTINATIONDIR" -type f -mtime +60 -name '*.pg_dump' -delete

    echo "Script finished"
else
    echo "Failed to mount '$BACKUPMOUNTPOINT'!"
fi
