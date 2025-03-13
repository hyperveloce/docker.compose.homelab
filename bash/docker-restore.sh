#!/bin/bash
# chmod +x docker-restore.sh

set -e  # Exit immediately if any command fails
set -o pipefail  # Catch errors in pipelines

# Define backup repository
REPO="/home/kanasu/kserver/docker.backup"

# Define directories for restore
RESTORE_DIR="/home/kanasu/kserver/docker.restore"
RESTORE_APP_DATA_DIR="$RESTORE_DIR/docker_app_data"
RESTORE_DB_DIR="$RESTORE_DIR/nextcloud_db"

# Create necessary restore directories
echo "Creating restore directories..."
mkdir -p "$RESTORE_APP_DATA_DIR" || { echo "Failed to create docker_app_data restore directory"; exit 1; }
mkdir -p "$RESTORE_DB_DIR" || { echo "Failed to create nextcloud_db restore directory"; exit 1; }

# List available backups
echo "Available backups in repository:"
borg list "$REPO"

# Ask the user to select a backup to restore
echo "Enter the name of the backup you want to restore (e.g., docker-app-backup-YYYY-MM-DD):"
read -r BACKUP_NAME

# Validate the backup exists
if ! borg list "$REPO" | grep -q "$BACKUP_NAME"; then
    echo "Backup $BACKUP_NAME does not exist!"
    exit 1
fi

# Restore the Docker app data and DB backup from Borg
echo "Restoring Docker app data..."
if ! borg extract "$REPO::$BACKUP_NAME" "$RESTORE_APP_DATA_DIR"; then
    echo "Failed to restore Docker app data!"
    exit 1
fi

echo "Restoring Nextcloud database..."
if ! borg extract "$REPO::$BACKUP_NAME" "$RESTORE_DB_DIR"; then
    echo "Failed to restore Nextcloud database!"
    exit 1
fi

# Restore database volume
DB_VOLUME="nextclouddb_data"
echo "Restoring database volume..."
if ! docker run --rm \
    -v "$DB_VOLUME:/source" \
    -v "$RESTORE_DB_DIR:/backup" \
    busybox cp -r /backup /source/; then
    echo "Failed to restore Docker volume $DB_VOLUME"
    exit 1
fi

# Validate the restored data
echo "Restoration complete. Please validate the following:"
echo "- Docker app data has been restored to $RESTORE_APP_DATA_DIR"
echo "- Nextcloud DB data has been restored to $RESTORE_DB_DIR"
echo "You can manually verify the data in the restore directories."

# Optionally, you
