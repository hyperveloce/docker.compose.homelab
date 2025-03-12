#!/bin/bash
#chmod +x docker-backup.sh

# Define backup repository
REPO="/home/kanasu/kserver/docker.backup"

# Define directory groups and corresponding backup names
BACKUP_GROUPS=(
    "nextcloud_group:/srv/data/nextcloud_data /srv/data/nextcloud_config /srv/data/nextcloud_themes"
    "pihole_homarr_group:/srv/data/pihole_etc-pihole /srv/data/pihole_etc-dnsmasq.d /srv/data/homarr_config"
)

# Define volumes to backup
VOLUMES=(
    "/srv/volume/nextclouddb_data"
)

# Define pruning policy
KEEP_DAILY=7
KEEP_WEEKLY=4
KEEP_MONTHLY=6

# Backup each group of directories
for group in "${BACKUP_GROUPS[@]}"; do
    # Split the group into backup name and directories
    IFS=":" read -r backup_name directories <<< "$group"

    # Append the date to the backup name
    backup_name="$backup_name-$(date +%Y-%m-%d)"

    # Backup the directories in the group
    echo "Backing up $backup_name..."
    borg create --stats "$REPO::$backup_name" $directories
done

# Backup Docker Volumes
for vol in "${VOLUMES[@]}"; do
    backup_name=$(basename "$vol")-$(date +%Y-%m-%d)
    echo "Backing up volume $vol..."
    borg create --stats "$REPO::$backup_name" "$vol"
done

# Prune old backups according to the policy
echo "Pruning old backups..."
borg prune --list --keep-daily=$KEEP_DAILY --keep-weekly=$KEEP_WEEKLY --keep-monthly=$KEEP_MONTHLY "$REPO"

echo "Backup and pruning complete."
