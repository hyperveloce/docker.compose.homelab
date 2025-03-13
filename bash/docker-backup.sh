#!/bin/bash
# chmod +x borg-backup.sh

set -e  # Exit immediately if any command fails
set -o pipefail  # Catch errors in pipelines

# Define the Borg repository (path where backups will be stored)
REPO="/home/kanasu/kserver/docker.backup"

# Define the source directory to back up
SOURCE_DIR="/srv/data/"

# Define the backup retention policy
KEEP_DAILY=7
KEEP_WEEKLY=4
KEEP_MONTHLY=6

# Create the backup
BACKUP_NAME="backup-$(date +%Y-%m-%d)"

echo "Starting backup of $SOURCE_DIR to $REPO::$BACKUP_NAME"

# Run Borg create to back up the directory
borg create --stats "$REPO::$BACKUP_NAME" "$SOURCE_DIR"

echo "Backup $BACKUP_NAME created successfully."

# Prune old backups according to the retention policy
echo "Pruning old backups..."

borg prune --list --keep-daily=$KEEP_DAILY --keep-weekly=$KEEP_WEEKLY --keep-monthly=$KEEP_MONTHLY "$REPO"

echo "Pruning complete."

echo "Backup process completed."
