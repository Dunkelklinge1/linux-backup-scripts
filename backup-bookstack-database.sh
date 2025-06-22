#!/bin/bash

BACKUPMOUNTPOINT="/mnt/backup" # Enty must exist in fstab
BACKUPTIME="$(date +%F_%H-%M)" # Get current date and time in format YYYY-mm-DD_HH-MM
BACKUPLABEL="bookstack-database-$BACKUPTIME"
DESTINATIONDIR="/mnt/backup/backup-data/mysqldump" # Root dir of all backups
DBUSER="bookstack" # DB user
DBPASSWORD="" # DB password
DBNAME="bookstack" # DB name

# Mount backup volume
mount $BACKUPMOUNTPOINT
# Check if backup volume is mounted (space after it prevents false positives with mountpoints that contains the same string)
if grep -qs "$BACKUPMOUNTPOINT " /proc/mounts; then
	# Create the destination dir
	mkdir -p $DESTINATIONDIR
	# Create database dump
	mariadb-dump --single-transaction -h localhost -u $DBUSER -p$DBPASSWORD $DBNAME > "$DESTINATIONDIR/$BACKUPLABEL.mysqldump"
	# Delete dumps older than 60 days
	find "$DESTINATIONDIR" -type f -mtime +60 -name '*.mysqldump' -delete

	echo "Script finished"
else
    echo "Failed to mount '$BACKUPMOUNTPOINT'!"
fi
