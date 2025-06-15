#!/bin/bash

# Setup backup directory
# RESTIC_PASSWORD_FILE=/home/kanasu/git.hyperveloce/docker.compose.homelab/.env restic init --repo /mnt/asus/kserver_backup/restic-backups

# Load environment variables from the .env file
set -a
source /home/kanasu/git.hyperveloce/docker.compose.homelab/.env
set +a

# Log file
LOG_FILE="/srv/data/log/restic-backup.log"

# Check if RESTIC_PASSWORD is available
if [ -z "$RESTIC_PASSWORD" ]; then
    echo "❌ RESTIC_PASSWORD not loaded. Check .env file." | tee -a "$LOG_FILE"
    exit 1
fi

# Check if the mount exists
BACKUP_MOUNT="/mnt/asus/kserver_backup"

BACKUP_PATHS=(
    "/srv/data"
)

echo "🔍 Checking if $BACKUP_MOUNT is mounted..." | tee -a "$LOG_FILE"
if ! mountpoint -q "$BACKUP_MOUNT"; then
    echo "❌ ERROR: Backup drive $BACKUP_MOUNT is not mounted. Exiting." | tee -a "$LOG_FILE"
    exit 1
fi

# Dump Nextcloud database using Docker
echo "📦 Dumping Nextcloud database using Docker..." | tee -a "$LOG_FILE"
docker run --rm --network app_network \
  -e MYSQL_PWD="$MYSQL_PASSWORD" \
  mysql:8.0 \
  mysqldump -h nc_db -u nextcloud nextcloud > /srv/data/db_backup/nextcloud.sql

if [ $? -ne 0 ]; then
    echo "❌ ERROR: Database dump failed!" | tee -a "$LOG_FILE"
    exit 1
fi

DAY_OF_WEEK=$(date +%u)

echo "🚀 Starting backup: $(date)" | tee -a "$LOG_FILE"

restic backup "${BACKUP_PATHS[@]}" \
  --repo "$BACKUP_MOUNT/restic-backups" \
  >> "$LOG_FILE" 2>&1

if [ "${PIPESTATUS[0]}" -ne 0 ]; then
    echo "❌ ERROR: Restic backup failed!" | tee -a "$LOG_FILE"
    exit 1
fi

# Retention policy on Sunday (7 = Sunday)
if [ "$DAY_OF_WEEK" -eq 7 ]; then
    echo "🧹 Applying retention policy..." | tee -a "$LOG_FILE"
    restic forget \
      --repo "$BACKUP_MOUNT/restic-backups" \
      --keep-daily 7 \
      --keep-weekly 2 \
      --keep-quarterly 2 \
      --prune >> "$LOG_FILE" 2>&1

    if [ "${PIPESTATUS[0]}" -ne 0 ]; then
        echo "❌ ERROR: Restic retention/prune failed!" | tee -a "$LOG_FILE"
        exit 1
    fi
fi

echo "✅ Backup completed successfully: $(date)" | tee -a "$LOG_FILE"
