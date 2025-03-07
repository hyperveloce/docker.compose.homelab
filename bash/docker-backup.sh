#!/bin/bash
#chmod +x docker-backup.sh
#crontab -e
#0 2 * * * /path/to/docker-backup.sh

# Define backup destination (adjust path as needed)
BACKUP_DIR="/path/to/backups"
TIMESTAMP=$(date +'%Y%m%d_%H%M%S')

# Create backup directory if it doesn't exist
mkdir -p "$BACKUP_DIR"

# Back up Nextcloud data
echo "Backing up Nextcloud data..."
docker run --rm --volumes-from nextcloud -v $BACKUP_DIR:/backup ubuntu bash -c "tar czf /backup/nextcloud_data_backup_$TIMESTAMP.tar.gz /var/www/html"

# Back up MariaDB data
echo "Backing up MariaDB data..."
docker run --rm --volumes-from db -v $BACKUP_DIR:/backup ubuntu bash -c "tar czf /backup/mariadb_backup_$TIMESTAMP.tar.gz /var/lib/mysql"

# Back up Redis data (if Redis is using persistence)
echo "Backing up Redis data..."
docker run --rm --volumes-from redis -v $BACKUP_DIR:/backup ubuntu bash -c "tar czf /backup/redis_backup_$TIMESTAMP.tar.gz /data"

# Confirmation message
echo "Backup completed successfully! Files saved as follows:"
echo "Nextcloud: nextcloud_data_backup_$TIMESTAMP.tar.gz"
echo "MariaDB: mariadb_backup_$TIMESTAMP.tar.gz"
echo "Redis: redis_backup_$TIMESTAMP.tar.gz"
