#!/bin/bash

BACKUPMOUNTPOINT="/mnt/backup" # Enty must exist in fstab
BACKUPTIME="$(date +%F_%H-%M)" # Get current date and time
BACKUPLABEL="root-$BACKUPTIME"
SOURCEDIR="/" # The directory that contains the files that we want to backup (in this case the entire system, but there are important exclusions below)
DESTINATIONDIR="/mnt/backup/backup-data/tar/root/weekly" # Root dir of all backups
DESTINATIONSUBDIR="$DESTINATIONDIR/$(date +%Y-%V)" # Weekly sub dir (full backup)

# Check if SOURCEDIR exists
if [ -d "$SOURCEDIR" ]; then
    # Mount backup volume
    mount $BACKUPMOUNTPOINT
    # Check if backup volume is mounted (space after it prevents false positives with mountpoints that contains the same string)
    if grep -qs "$BACKUPMOUNTPOINT " /proc/mounts; then
        # Create destination sub dir if it not exists
        mkdir -p "$DESTINATIONSUBDIR"

        # Get number of .tar.gz files to determine the backup level
        BACKUPLEVEL="$(find $DESTINATIONSUBDIR -maxdepth 1 -type f -name '*.tar.gz' | wc -l)"
        # If it's the first archive in this sub dir, then...
        if [ $BACKUPLEVEL -eq 0 ]; then
            # ...create archive using bsdtar.
            # This will only back up the root file system and no other file systems like /mnt or /media.
            # Also exlude .qcow and .img files as well as /swapfile.
            # This backup file has the suffix ".bsdtar.tar.gz". There will only be one such file per sub dir.
            bsdtar --exclude="*.qcow2" --exclude="*.img" --exclude="/swapfile" --one-file-system --acls --xattrs -cpzvf "$DESTINATIONSUBDIR/$BACKUPLABEL.bsdtar.tar.gz" "$SOURCEDIR"
            # bsdtar is able to preserve extended attributes and handles sparse files more efficient then gnutar/tar.
            # Use this full backup file to recover the whole system.
            # Unlike gnutar/tar it is not able to create incremental archives.
        else
            # ...otherwise create the *incremental* archive using tar.
            # This will only back up the root file system and no other file systems like /mnt or /media.
            # Also exlude .qcow and .img files as well as /swapfile.
            # This will also create a full backup if there is no incremental-list.snar (this file will be created on the first run).
            tar --exclude="*.qcow2" --exclude="*.img" --exclude="/swapfile" -vcpSzg "$DESTINATIONSUBDIR/incremental-list.snar" -f "$DESTINATIONSUBDIR/$BACKUPLABEL.gnutar.tar.gz" --one-file-system "$SOURCEDIR"
            # If you are restoring the entire system, use the ".bsdtar.tar.gz" backup file first!
            # Later, on the restored system, use the ".gnutar.tar.gz" files to selectively restore the remaining files you need.
            # To do this, you must first restore the first full gnutar archive to a separately mounted drive.
            # Then continue with the next incremental gnutar archive created the next day until all archives are extracted and copy your files to the right place.
        fi

        # If exit status 0...
        if [ $? -eq 0 ]; then
            # ...then delete sub dirs older than 14 days (5 weeks)
            find "$DESTINATIONDIR" -type d -mtime +14 -exec rm -r {} \;
        fi

        echo "Script finished"
    else
        echo "Failed to mount '$BACKUPMOUNTPOINT'!"
    fi
else
    echo "'${SOURCEDIR}' does not exist!"
fi
