#!/bin/bash
#chmod +x docker-restore.sh
#./docker-restore.sh

# Define backup directory (default to current directory)
BACKUP_DIR=$(pwd)

# Check if backup files exist
if [[ ! -f "$BACKUP_DIR/nextcloud_data_backup.tar.gz" || ! -f "$BACKUP_DIR/mariadb_backup.tar.gz" || ! -f "$BACKUP_DIR/redis_backup.tar.gz" ]]; then
  echo "Backup files are missing! Make sure nextcloud_data_backup.tar.gz, mariadb_backup.tar.gz, and redis_backup.tar.gz exist."
  exit 1
fi

# Stop the containers before restoring data
echo "Stopping containers..."
docker-compose down

# Restore Nextcloud data
echo "Restoring Nextcloud data..."
docker run --rm --volumes-from nextcloud -v $BACKUP_DIR:/backup ubuntu bash -c "tar xzf /backup/nextcloud_data_backup.tar.gz -C /var/www/html"

# Restore MariaDB data
echo "Restoring MariaDB data..."
docker run --rm --volumes-from db -v $BACKUP_DIR:/backup ubuntu bash -c "tar xzf /backup/mariadb_backup.tar.gz -C /var/lib/mysql"

# Restore Redis data (if Redis persistence is enabled)
echo "Restoring Redis data..."
docker run --rm --volumes-from redis -v $BACKUP_DIR:/backup ubuntu bash -c "tar xzf /backup/redis_backup.tar.gz -C /data"

# Start the containers again
echo "Starting containers..."
docker-compose up -d

echo "Restore completed successfully!"
