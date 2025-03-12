#!/bin/bash
#chmod +x docker-backup.sh

# Define backup repository
REPO="/home/kanasu/kserver/docker.backup"

# Define Nextcloud directories to backup
NEXTCLOUD_DIRECTORIES=(
    "/srv/data/nextcloud_data"
    "/srv/data/nextcloud_config"
    "/srv/data/nextcloud_themes"
)

# Define other directories to backup
OTHER_DIRECTORIES=(
    "/srv/data/pihole_etc-pihole"
    "/srv/data/pihole_etc-dnsmasq.d"
    "/srv/data/homarr_config"
    "nginxpm_data/"
    "nginxpm_letsencrypt/"
)

# Define volumes to backup
VOLUMES=(
    "/srv/volume/nextclouddb_data"
)

# Define pruning policy
KEEP_DAILY=7
KEEP_WEEKLY=4
KEEP_MONTHLY=6

# Backup Nextcloud Directories
for dir in "${NEXTCLOUD_DIRECTORIES[@]}"; do
    backup_name="nextcloud_$(basename "$dir")-$(date +%Y-%m-%d)"
    borg create --stats "$REPO::$backup_name" "$dir"
done

# Backup Other Directories
for dir in "${OTHER_DIRECTORIES[@]}"; do
    backup_name="other_$(basename "$dir")-$(date +%Y-%m-%d)"
    borg create --stats "$REPO::$backup_name" "$dir"
done

# Backup Docker Volumes
for vol in "${VOLUMES[@]}"; do
    backup_name="volume_$(basename "$vol")-$(date +%Y-%m-%d)"
    borg create --stats "$REPO::$backup_name" "$vol"
done

# Backup the original volume (if necessary, specify the volume directory here)
VOLUME="/srv/volume/nextclouddb_data"
backup_name="original_volume-$(date +%Y-%m-%d)"
borg create --stats "$REPO::$backup_name" "$ORIGINAL_VOLUME"

# Prune old backups according to the policy
echo "Pruning old backups..."
borg prune --list --keep-daily=$KEEP_DAILY --keep-weekly=$KEEP_WEEKLY --keep-monthly=$KEEP_MONTHLY "$REPO"

echo "Backup and pruning complete."
