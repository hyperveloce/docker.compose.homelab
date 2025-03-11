#!/bin/bash
#chmod +x docker-backup.sh
#crontab -e
#0 2 * * * /path/to/docker-backup.sh

# Backup location
BACKUP_DIR="/home/kanasu/docker.backup/nextcloud_backups"
NEXTCLOUD_DIR="/srv/data/nextcloud"
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")

# Create versioned backup folder
mkdir -p "$BACKUP_DIR/$TIMESTAMP"

echo "Starting Nextcloud versioned backup..."

# Backup bind-mounted data
echo "Backing up data, config, and themes..."
rsync -av --progress $NEXTCLOUD_DIR/nextcloud_data "$BACKUP_DIR/$TIMESTAMP/"
rsync -av --progress $NEXTCLOUD_DIR/nextcloud_themes "$BACKUP_DIR/$TIMESTAMP/"
rsync -av --progress $NEXTCLOUD_DIR/nextcloud_config "$BACKUP_DIR/$TIMESTAMP/"

# Backup Docker volumes
echo "Backing up Docker volumes..."

docker run --rm \
  -v nextcloud_db:/db_backup \
  -v "$BACKUP_DIR/$TIMESTAMP":/backup \
  busybox tar czf /backup/nextcloud_db_backup.tar.gz /db_backup

# Keep the last 7 backups (rolling retention policy)
echo "Cleaning up old backups..."
find "$BACKUP_DIR" -type d -mtime +7 -exec rm -rf {} +

echo "Backup completed successfully! Stored at: $BACKUP_DIR/$TIMESTAMP"
