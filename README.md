# linux-backup-scripts
A repository of all my battle proven backup scripts.
I use them myself for my servers, where the backups have proven to be reliable even for full system recoveries.

The scripts depend on multiple backup, compression and archiving tools.
Make sure you have all of them installed:
- **xfsdump** (for XFS file system dump)
- **lzop** (for fast and lightweight compression)
- **borg-backup** (for file and directory backups)
- **bsdtar** (for standard file and directory archiving)
- **mariadb-dump, pg_dump** (for database dump)
