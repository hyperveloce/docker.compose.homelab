#!/bin/bash

# Load environment variables from the .env file
set -a
source /home/kanasu/git.hyperveloce/docker.compose.homelab/.env
set +a

# === Ensure mount exists ===
BACKUP_MOUNT="/mnt/asus/kserver_backup"
echo "Checking if $BACKUP_MOUNT is mounted..."
sudo mount -a

if ! mountpoint -q "$BACKUP_MOUNT"; then
    echo "Mount failed or not present. Exiting."
    exit 1
fi

# === Config ===
LOG_FILE="/home/kanasu/kserver/restic-backup.log"

# Directories to back up
BACKUP_PATHS=(
    "/srv/data"
    "/srv/db_backup"
)

# Repositories to back up to
BACKUP_REPOSITORIES=(
    "/mnt/asus/kserver_backup/restic-backups"
)

DAY_OF_WEEK=$(date +%u)

# === MySQL Docker Dump ===
DB_DUMP_DIR="/srv/db_backup"
mkdir -p "$DB_DUMP_DIR"

# Clean up any previous dump
rm -f "$DB_DUMP_DIR/nextcloud.sql"

# Docker-based mysqldump
echo "Dumping Nextcloud database using Docker..." | tee -a "$LOG_FILE"
docker run --rm --network app_network \
    -e MYSQL_PWD="${MYSQL_PASSWORD}" \
    mysql:8.0 \
    mysqldump -h nc_db -u nextcloud nextcloud > "$DB_DUMP_DIR/nextcloud.sql"

if [ $? -ne 0 ]; then
    echo "❌ Database dump failed. Exiting." | tee -a "$LOG_FILE"
    exit 1
fi

# === Restic backup ===
echo "Starting backup: $(date)" | tee -a "$LOG_FILE"

for REPO in "${BACKUP_REPOSITORIES[@]}"; do
    echo "Backing up to repository: $REPO" | tee -a "$LOG_FILE"
    restic backup "${BACKUP_PATHS[@]}" \
        --repo "$REPO" \
        2>&1 | tee -a "$LOG_FILE"
done

# === Retention policy ===
if [ "$DAY_OF_WEEK" -eq 7 ]; then
    echo "Applying local retention policy..." | tee -a "$LOG_FILE"
    for REPO in "${BACKUP_REPOSITORIES[@]}"; do
        if [ "$REPO" != "/mnt/offsite_nas/restic-backups" ]; then
            echo "Pruning local or network backup: $REPO" | tee -a "$LOG_FILE"
            restic forget \
                --repo "$REPO" \
                --keep-daily 7 \
                --keep-weekly 2 \
                --keep-quarterly 2 \
                --prune \
                2>&1 | tee -a "$LOG_FILE"
        fi
    done

    echo "Applying offsite retention policy..." | tee -a "$LOG_FILE"
    restic forget \
        --repo "/mnt/offsite_nas/restic-backups" \
        --keep-weekly 2 \
        --keep-quarterly 2 \
        --prune \
        2>&1 | tee -a "$LOG_FILE"
fi

echo "Backup completed: $(date)" | tee -a "$LOG_FILE"
