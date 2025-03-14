#!/bin/bash
#chmod +x ~/restic-restore.sh

# Config
RESTIC_REPOSITORY="/home/kanasu/kserver/restic.backups"
RESTIC_PASSWORD_FILE="/home/kanasu/kserver/empty-password.txt"
RESTORE_DIR="/srv/restore"
LOG_FILE="/home/kanasu/kserver/restic-restore.log"

# Optional: List available snapshots
echo "Available snapshots:" | tee -a "$LOG_FILE"
restic snapshots --repo "$RESTIC_REPOSITORY" --password-file "$RESTIC_PASSWORD_FILE" | tee -a "$LOG_FILE"

# Ask for a snapshot ID to restore (optional: set this manually)
echo "Enter the snapshot ID to restore (press Enter for the latest snapshot):"
read -r SNAPSHOT_ID

# If no ID is provided, use the latest snapshot
if [ -z "$SNAPSHOT_ID" ]; then
    SNAPSHOT_ID=$(restic snapshots --repo "$RESTIC_REPOSITORY" --password-file "$RESTIC_PASSWORD_FILE" --json | jq -r '.[-1].id')
    echo "Using latest snapshot: $SNAPSHOT_ID" | tee -a "$LOG_FILE"
fi

# Start restore
echo "Restoring snapshot $SNAPSHOT_ID to $RESTORE_DIR..." | tee -a "$LOG_FILE"
restic restore "$SNAPSHOT_ID" \
    --repo "$RESTIC_REPOSITORY" \
    --password-file "$RESTIC_PASSWORD_FILE" \
    --target "$RESTORE_DIR" \
    --exclude ".restic" # Exclude Restic metadata

# Finish
echo "Restore completed: $(date)" | tee -a "$LOG_FILE"
