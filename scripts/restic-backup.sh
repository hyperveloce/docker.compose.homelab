#!/bin/bash

# Setup backup directory
# RESTIC_PASSWORD_FILE=/home/kanasu/git.hyperveloce/docker.compose.homelab/.env restic init --repo /mnt/asus/kserver_backup/restic-backups
# restic init --repo /mnt/asus/kserver_backup/restic-backups

# === CONFIGURATION ===
ENV_FILE="/home/kanasu/git.hyperveloce/docker.compose.homelab/.env"
LOG_FILE="/srv/data/log/restic-backup.log"
BACKUP_MOUNT="/mnt/asus/kserver_backup"
REPO_PATH="$BACKUP_MOUNT/restic-backups"
RESTIC_BIN="$(which restic)"
BACKUP_PATHS=("/srv/data")
NEXTCLOUD_DB_DUMP="/srv/data/db_backup/nextcloud.sql"

# === LOAD ENVIRONMENT VARIABLES ===
if [ -f "$ENV_FILE" ]; then
    set -a
    source "$ENV_FILE"
    set +a
else
    echo "❌ ERROR: .env file not found at $ENV_FILE" | tee -a "$LOG_FILE"
    exit 1
fi

# Unset RESTIC_PASSWORD_FILE if set, to avoid file lookup
unset RESTIC_PASSWORD_FILE

# === CHECK RESTIC PASSWORD ===
if [ -z "$RESTIC_PASSWORD" ]; then
    echo "❌ RESTIC_PASSWORD not loaded. Check .env file." | tee -a "$LOG_FILE"
    exit 1
fi

# === CHECK BACKUP DRIVE ===
echo "🔍 Checking if $BACKUP_MOUNT is mounted..." | tee -a "$LOG_FILE"
if ! mountpoint -q "$BACKUP_MOUNT"; then
    echo "❌ ERROR: Backup drive $BACKUP_MOUNT is not mounted. Exiting." | tee -a "$LOG_FILE"
    exit 1
fi

# === DUMP NEXTCLOUD DATABASE ===
echo "📦 Dumping Nextcloud database using Docker..." | tee -a "$LOG_FILE"
docker run --rm --network app_network \
  -e MYSQL_PWD="$MYSQL_PASSWORD" \
  mysql:8.0 \
  mysqldump -h nc_db -u nextcloud nextcloud > "$NEXTCLOUD_DB_DUMP"

if [ $? -ne 0 ]; then
    echo "❌ ERROR: Database dump failed!" | tee -a "$LOG_FILE"
    exit 1
fi

# === RUN RESTIC BACKUP ===
echo "🚀 Starting backup: $(date)" | tee -a "$LOG_FILE"
$RESTIC_BIN backup "${BACKUP_PATHS[@]}" \
  --repo "$REPO_PATH" >> "$LOG_FILE" 2>&1

if [ "${PIPESTATUS[0]}" -ne 0 ]; then
    echo "❌ ERROR: Restic backup failed!" | tee -a "$LOG_FILE"
    exit 1
fi

# === RETENTION POLICY ON SUNDAYS ===
DAY_OF_WEEK=$(date +%u)  # 7 = Sunday
if [ "$DAY_OF_WEEK" -eq 7 ]; then
    echo "🧹 Applying retention policy..." | tee -a "$LOG_FILE"
    $RESTIC_BIN forget \
      --repo "$REPO_PATH" \
      --keep-daily 7 \
      --keep-weekly 2 \
      --keep-monthly 2 \
      --prune >> "$LOG_FILE" 2>&1

    if [ "${PIPESTATUS[0]}" -ne 0 ]; then
        echo "❌ ERROR: Restic retention/prune failed!" | tee -a "$LOG_FILE"
        exit 1
    fi
fi

# === DONE ===
echo "✅ Backup completed successfully: $(date)" | tee -a "$LOG_FILE"
