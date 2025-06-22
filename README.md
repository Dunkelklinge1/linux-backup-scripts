# linux-backup-scripts
A repository of all my battle proven backup scripts.
I use them myself for my servers, where the backups have proven to be reliable even in case of full system recovery.

The scripts depend on multiple backup, compression and archiving tools.
- **xfsdump** (XFS file system dump)
- **lzop** (fast and lightweight compression)
- **borg-backup** (file and directory version backups)
- **bsdtar** (standard file and directory archiving)
- **mariadb-dump, pg_dump** (database dump)
