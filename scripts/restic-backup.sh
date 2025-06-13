#!/bin/bash

# Load environment variables from the .env file
set -a
source /home/kanasu/git.hyperveloce/docker.compose.homelab/.env
set +a

# Check if the mount exists
BACKUP_MOUNT="/mnt/asus/kserver_backup"
echo "Checking if $BACKUP_MOUNT is mounted..."

if ! mountpoint -q "$BACKUP_MOUNT"; then
    echo "ERROR: Backup drive $BACKUP_MOUNT is not mounted. Exiting."
    exit 1
fi

# Dump Nextcloud database using Docker
echo "Dumping Nextcloud database using Docker..."
docker run --rm --network app_network \
  -e MYSQL_PWD="$MYSQL_PASSWORD" \
  mysql:8.0 \
  mysqldump -h nc_db -u nextcloud > /srv/db_backup/nextcloud.sql

# Log file
LOG_FILE="/home/kanasu/kserver/restic-backup.log"

DAY_OF_WEEK=$(date +%u)

echo "Starting backup: $(date)" | tee -a "$LOG_FILE"

# Manual restic backup
restic backup /srv/data \
  --repo /mnt/asus/kserver_backup/restic-backups \
  >> "$LOG_FILE" 2>&1

# Retention policy
if [ "$DAY_OF_WEEK" -eq 7 ]; then
    echo "Applying retention policy..." | tee -a "$LOG_FILE"
    restic forget \
      --repo /mnt/asus/kserver_backup/restic-backups \
      --keep-daily 7 \
      --keep-weekly 2 \
      --keep-quarterly 2 \
      --prune >> "$LOG_FILE" 2>&1
fi

echo "Backup completed: $(date)" | tee -a "$LOG_FILE"
