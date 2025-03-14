#!/bin/bash
#chmod +x restic-restore.sh

# Config
RESTIC_REPOSITORY=/home/kanasu/kserver/restic.backups
RESTIC_PASSWORD_FILE=/home/kanasu/kserver/restic-pw.txt
LOG_FILE="/home/kanasu/kserver/restic-restore.log"
RESTORE_TARGET="/srv/restore"  # Path to restore the backup

# Function to restore the latest snapshot
restore_latest_snapshot() {
    echo "Restoring the latest snapshot..." | tee -a "$LOG_FILE"

    # Find the latest snapshot (most recent one based on creation time)
    LATEST_SNAPSHOT=$(restic snapshots --json | jq -r '.[-1].id')

    if [ -z "$LATEST_SNAPSHOT" ]; then
        echo "No snapshot found. Aborting restore." | tee -a "$LOG_FILE"
        exit 1
    fi

    # Restore both /srv/volume and /srv/data from the latest snapshot
    echo "Restoring snapshot $LATEST_SNAPSHOT to $RESTORE_TARGET" | tee -a "$LOG_FILE"

    # Restore /srv/volume
    restic restore "$LATEST_SNAPSHOT" --repo "$RESTIC_REPOSITORY" --password-file "$RESTIC_PASSWORD_FILE" --target "$RESTORE_TARGET/srv/volume" --path "/srv/volume"

    # Restore /srv/data
    restic restore "$LATEST_SNAPSHOT" --repo "$RESTIC_REPOSITORY" --password-file "$RESTIC_PASSWORD_FILE" --target "$RESTORE_TARGET/srv/data" --path "/srv/data"

    if [ $? -eq 0 ]; then
        echo "Restore completed successfully." | tee -a "$LOG_FILE"
    else
        echo "Restore failed." | tee -a "$LOG_FILE"
        exit 1
    fi
}

# Start restore process
echo "Starting restore: $(date)" | tee -a "$LOG_FILE"
restore_latest_snapshot

# Finish
echo "Restore completed: $(date)" | tee -a "$LOG_FILE"
