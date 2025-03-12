#!/bin/bash
#chmod +x docker-backup.sh

# Define backup repository
REPO="/home/kanasu/kserver/docker.backup"

# Define backup groups
BACKUP_GROUPS=(
    "nextcloud_group:/srv/data/nextcloud_data /srv/data/nextcloud_config /srv/data/nextcloud_themes"
    "pihole_homarr_group:/srv/data/pihole_etc-pihole /srv/data/pihole_etc-dnsmasq.d /srv/data/homarr_config"
    "nginxpm_group:/srv/data/nginxpm_data /srv/data/nginxpm_letsencrypt"
)

# Define Docker volumes to back up
VOLUMES=(
    "/srv/volume/nextclouddb_data"
)

# Define pruning policy
KEEP_DAILY=7
KEEP_WEEKLY=4
KEEP_MONTHLY=6

# Loop through backup groups and create backups
for group in "${BACKUP_GROUPS[@]}"; do
    # Split the group string into name and directories
    GROUP_NAME=$(echo "$group" | cut -d: -f1)
    DIRECTORIES=$(echo "$group" | cut -d: -f2-)

    # Create the backup for this group
    backup_name="${GROUP_NAME}-$(date +%Y-%m-%d)"
    borg create --stats "$REPO::$backup_name" $DIRECTORIES
done

# Backup Docker Volumes
for vol in "${VOLUMES[@]}"; do
    backup_name="volumes-$(date +%Y-%m-%d)"
    borg create --stats "$REPO::$backup_name" "$vol"
done

# Prune old backups according to the policy
echo "Pruning old backups..."
borg prune --list --keep-daily=$KEEP_DAILY --keep-weekly=$KEEP_WEEKLY --keep-monthly=$KEEP_MONTHLY "$REPO"

echo "Backup and pruning complete."
