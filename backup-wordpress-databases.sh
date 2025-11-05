#!/bin/bash

BACKUPMOUNTPOINT="/mnt/backup" # Enty must exist in fstab
BACKUPTIME="$(date +%F_%H-%M)" # Get current date and time in format YYYY-mm-DD_HH-MM
BACKUPLABEL1="wp-someinstance-database-$BACKUPTIME"
#BACKUPLABEL2="wp-someotherinstance-database-$BACKUPTIME"
DESTINATIONDIR="/mnt/backup/backup-data/mysqldump" # Root dir of all backups

# Mount backup volume
mount $BACKUPMOUNTPOINT
# Check if backup volume is mounted (space after it prevents false positives with mountpoints that contains the same string)
if grep -qs "$BACKUPMOUNTPOINT " /proc/mounts; then
    # Create the destination dir
    mkdir -p $DESTINATIONDIR
    # Create database dumps
    mariadb-dump --single-transaction -h localhost -u wp_someinstance -p'XXXXXXXXXX' wp_someinstance > "$DESTINATIONDIR/$BACKUPLABEL1.mysqldump"
    #mariadb-dump --single-transaction -h localhost -u wp_someotherinstance -p'XXXXXXXXXX' wp_someotherinstance > "$DESTINATIONDIR/$BACKUPLABEL2.mysqldump"
    # Delete dumps older than 60 days
    find "$DESTINATIONDIR" -type f -mtime +60 -name '*.mysqldump' -delete

    echo "Script finished"
else
    echo "Failed to mount '$BACKUPMOUNTPOINT'!"
fi
