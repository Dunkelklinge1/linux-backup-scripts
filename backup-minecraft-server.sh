#!/bin/bash

function rcon {
    /mnt/data/minecraft/mcrcon/mcrcon -H 127.0.0.1 -P 25575 -p XXXXXXXXXXXXXXXXXXXXXXXX "$1"
    # More MC servers can be added here (each with different Rcon port)
}

BACKUPMOUNTPOINT="/mnt/backup" # Enty must exist in fstab
BACKUPTIME="$(date +%F_%H-%M)" # Get current date and time in format YYYY-mm-DD_HH-MM
BACKUPLABEL="minecraft-$BACKUPTIME"
SOURCEDIR="/mnt/data/minecraft" # The directory that contains the files that we want to backup
DESTINATIONDIR="/mnt/backup/backup-data/borg" # Root dir of all backups and thus our Borg repository

# Check if SOURCEDIR exists
if [ -d "$SOURCEDIR" ]; then
    # Mount backup volume
    mount $BACKUPMOUNTPOINT
    # Check if backup volume is mounted (space after it prevents false positives with mountpoints that contains the same string)
    if grep -qs "$BACKUPMOUNTPOINT " /proc/mounts; then
        # Create the destination dir
        mkdir -p $DESTINATIONDIR

        # Telling the players that a backup is about to start (in red color)
        rcon "tellraw @a {\"text\":\"[SERVER] Starting daily backup...\",\"color\":\"red\"}"
        # Turn off auto-save (and save the world one last time before backup is starting)
        rcon "save-off"
        rcon "save-all"
        sleep 20

        # Create the Borg repo if there is none
        borg init --encryption=none $DESTINATIONDIR
        # Create the incremental archive using Borg (only selected file system and no other ones even if mounted)
        borg create --stats --progress --one-file-system --compression=zstd,8 $DESTINATIONDIR::$BACKUPLABEL $SOURCEDIR
        # Keep only backups within 30 days and last 10 weekly (sunday) ones
        borg prune -v --list --keep-within=30d --keep-weekly=10 $DESTINATIONDIR
        # Free up disk space
        borg compact $DESTINATIONDIR

        # Turn on world saving again and tell the players that the backup has finished (in green color)
        rcon "save-on"
        rcon "tellraw @a {\"text\":\"[SERVER] Backup finished.\",\"color\":\"green\"}"

        echo "Script finished"
    else
        echo "Failed to mount '$BACKUPMOUNTPOINT'!"
    fi
else
    echo "'${SOURCEDIR}' does not exist!"
fi
