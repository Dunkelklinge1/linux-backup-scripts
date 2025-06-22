#!/bin/bash

BACKUPMOUNTPOINT="/mnt/backup" # Enty must exist in fstab
BACKUPTIME="$(date +%F_%H-%M)" # Get current date and time
BACKUPLABEL="root-$BACKUPTIME"
SOURCEDIR="/" # The directory that contains the files that we want to backup (in this case the entire system, but there are important exclusions below)
DESTINATIONDIR="/mnt/backup/backup-data/xfsdump/root/weekly" # Root dir of all backups
DESTINATIONSUBDIR="$DESTINATIONDIR/$(date +%Y-%V)" # Weekly sub dir (full backup)

# Check if SOURCEDIR exists
if [ -d "$SOURCEDIR" ]; then
    # Mount backup volume
    mount $BACKUPMOUNTPOINT
    # Check if backup volume is mounted (space after it prevents false positives with mountpoints that contains the same string)
    if grep -qs "$BACKUPMOUNTPOINT " /proc/mounts; then
        # Create destination sub dir if it not exists
        mkdir -p "$DESTINATIONSUBDIR"

        # Create the incremental archive using tar (only root file system and no other file systems like /mnt or /media)
        #tar -vvcpSzg "$DESTINATIONSUBDIR/listed-incremental.snar" -f "$DESTINATIONSUBDIR/archive-$BACKUPTIME.tar.gz" --one-file-system "$SOURCEDIR"

        # Get number or xfsdump files to determine the backup level
        BACKUPLEVEL="$(find $DESTINATIONSUBDIR -maxdepth 1 -type f -name '*.xfsdump' -o -name '*.xfsdump.lzo' | wc -l)"
        # Create the incremental archive using xfsdump (only root file system and no other file systems like /mnt or /media)
        # The xfsdump is piped through lzop which uses fast LZO compression
        xfsdump -L $BACKUPLABEL -M backup_to_file -l $BACKUPLEVEL -v verbose - $SOURCEDIR | lzop > $DESTINATIONSUBDIR/$BACKUPLABEL.xfsdump.lzo

        # If exit status 0...
        if [ $? -eq 0 ]; then
            # ...then delete sub dirs older than 14 days
            find "$DESTINATIONDIR" -type d -mtime +14 -exec rm -r {} \;
        fi

        echo "Script finished"
    else
        echo "Failed to mount '$BACKUPMOUNTPOINT'!"
    fi
else
    echo "'${SOURCEDIR}' does not exist!"
fi
