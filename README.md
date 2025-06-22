# linux-backup-scripts
A repository of all my battle tested backup scripts.
I use them myself for my servers. The backups these scripts create have proven to be reliable even in case of full system recovery.

The scripts depend on following list of backup, compression and archiving tools.
Credit goes to these projects!
- **xfsdump** (XFS file system dump)
- **lzop** (fast and lightweight compression)
- **zstd** (multi-threaded, fast compression)
- **borg-backup** (file and directory version backups)
- **bsdtar** (standard file and directory archiving)
- **mariadb-dump, pg_dump** (database dump)
- **rsync** (used for offsite backup transfer)

# Features
To see which script has which feature, take a look into the script itself. It has plenty of comments to describe what it's doing.
- File structure, database and full system backup
- Incremential backup
- Compression
- Cleanup of old backups
- Data deduplication (thanks to borg-backup)
- Offsite backup transfer

# Usage
The scripts are custom made to fit my own infrastructure.
If you want to use some scripts for your own systems:
- Take a look into each scripts and check what they depend on (for example, I mostly use XFS as file system, therefore xfsdump is used by the script).
- At very least you need to modify the variables at the top of each script and adapt it to your own needs.
- Combine the features of multiple scripts (for exampe for a full Nextcloud server backup use backup-root.sh, backup-nextcloud-database.sh and backup-mnt-data.sh) and use a wrapper script to execute them.
- Use cron or systemd to execte each script on regular basis.
- A backup is only as good as the recovery. Test your backups regularly for recoverability!
- If possible additionally transfer your backups to another physical location (see backup-offsite.sh).

# Purpose of each script
- **backup-vh-root.sh**: Backup the bare metal system of a KVM/QEMU hypervisor without VM images (backup suitable for system recovery)
- **backup-root.sh**: Backup bare metal system installed on a XFS file system (backup suitable for system recovery)
- **backup-omv-root.sh**: Backup bare metal Open Media Vault (OMV) based system (backup suitable for system recovery)
- **backup-nextcloud-database.sh**: Backup Nextcloud MariaDB database (does not backup the file structure)
- **backup-bookstack-database.sh**: Backup Bookstack MariaDB database (does not backup the file structure)
- **backup-matrix-synapse-database.sh**: Backup Matrix Synapse ProstreSQL database (does not backup the file structure)
- **backup-minecraft-server.sh**: Backup file structure of Minecraft server
- **backup-mnt-data.sh**: Backup file structure of /mnt/data
- **backup-omv-userdata.sh**: Backup file structure of a volume mounted by OMV
- **backup-offsite.sh**: Transfer backups to another physical location via rsync
