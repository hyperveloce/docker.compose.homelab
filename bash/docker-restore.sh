#!/bin/bash
# chmod +x docker-restore.sh

# Define backup repository
REPO="/home/kanasu/kserver/docker.backup"

# Define directories and volumes to restore
DIRECTORIES=(
    "/srv/data/nextcloud_data"
    "/srv/data/nextcloud_config"
    "/srv/data/nextcloud_themes"
    "/srv/data/pihole_etc-pihole"
    "/srv/data/pihole_etc-dnsmasq.d"
    "/srv/data/homarr_config"
)

VOLUMES=(
    "/srv/volume/nextclouddb_data"
)

# Prompt for restore date
echo "Enter the date of the backup to restore (YYYY-MM-DD):"
read BACKUP_DATE

# Restore Directories
for dir in "${DIRECTORIES[@]}"; do
    backup_name=$(basename "$dir")-$BACKUP_DATE
    echo "Restoring $dir from backup $backup_name..."
    borg extract "$REPO::$backup_name" "$dir"
done

# Restore Docker Volumes
for vol in "${VOLUMES[@]}"; do
    backup_name=$(basename "$vol")-$BACKUP_DATE
    echo "Restoring $vol from backup $backup_name..."
    borg extract "$REPO::$backup_name" "$vol"
done

echo "Restore complete."
