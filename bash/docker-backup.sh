#!/bin/bash
# chmod +x docker-backup.sh

set -e  # Exit immediately if any command fails
set -o pipefail  # Catch errors in pipelines

# Define backup repository
REPO="/home/kanasu/kserver/docker.backup"

# Define Docker app data paths
DOCKER_APP_DATA=(
    "/srv/data/nextcloud_data"
    "/srv/data/nextcloud_config"
    "/srv/data/nextcloud_themes"
    "/srv/data/pihole_etc-pihole"
    "/srv/data/pihole_etc-dnsmasq.d"
    "/srv/data/homarr_config"
    "/srv/data/nginxpm_data"
    "/srv/data/nginxpm_letsencrypt"
)

# Define Nextcloud database dump path
DB_DUMP_PATH="$REPO/nextcloud_db"

# Create necessary directories
echo "Creating backup directories..."
mkdir -p "$REPO/docker_app_data" || { echo "Failed to create docker_app_data directory"; exit 1; }
mkdir -p "$DB_DUMP_PATH" || { echo "Failed to create nextcloud_db directory"; exit 1; }

# Dump the Nextcloud database
echo "Dumping Nextcloud database..."
if ! docker exec nextcloud-db-container mysqldump -u root -p<password> nextcloud > "$DB_DUMP_PATH/nextcloud-db-$(date +%Y-%m-%d).sql"; then
    echo "Database dump failed!"
    exit 1
fi

# Back up Docker app data
echo "Backing up Docker app data..."
for dir in "${DOCKER_APP_DATA[@]}"; do
    if [ -d "$dir" ]; then
        if ! rsync -av --delete "$dir/" "$REPO/docker_app_data/"; then
            echo "Failed to sync $dir"
            exit 1
        fi
    else
        echo "WARNING: Directory $dir does not exist. Skipping."
    fi
done

# Create Borg backup
backup_name="docker-app-backup-$(date +%Y-%m-%d)"
echo "Creating Borg backup: $backup_name"
if ! borg create --stats "$REPO::$backup_name" "$REPO/docker_app_data" "$DB_DUMP_PATH"; then
    echo "Borg backup failed!"
    exit 1
fi

# Prune old backups
KEEP_DAILY=7
KEEP_WEEKLY=4
KEEP_MONTHLY=6

echo "Pruning old backups..."
if ! borg prune --list --keep-daily=$KEEP_DAILY --keep-weekly=$KEEP_WEEKLY --keep-monthly=$KEEP_MONTHLY "$REPO"; then
    echo "Backup pruning failed!"
    exit 1
fi

echo "Backup and pruning complete."
