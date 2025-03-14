#!/bin/bash
#chmod +x restic-restore.sh

# Config
RESTIC_REPOSITORY=/home/kanasu/kserver/restic.backups
RESTIC_PASSWORD_FILE=/home/kanasu/kserver/restic-pw.txt
LOG_FILE="/home/kanasu/kserver/restic-restore.log"
RESTORE_TARGET="/srv/restore"  # Path to restore the backup

# Set the environment variable for restic repository
export RESTIC_REPOSITORY
export RESTIC_PASSWORD_FILE

# Check if repository exists
if [ ! -d "$RESTIC_REPOSITORY" ]; then
    echo "Restic repository not found at $RESTIC_REPOSITORY. Aborting restore." | tee -a "$LOG_FILE"
    exit 1
fi

# Function to restore the latest snapshot
restore_latest_snapshot() {
    echo "Restoring the latest snapshot..." | tee -a "$LOG_FILE"

    # Find the latest snapshot using restic command without jq
    LATEST_SNAPSHOT=$(restic snapshots --repo "$RESTIC_REPOSITORY" --latest 1 --json | grep -o '"id":"[^"]*' | head -n 1 | cut -d: -f2 | tr -d '"')

    if [ -z "$LATEST_SNAPSHOT" ]; then
        echo "No snapshot found. Aborting restore." | tee -a "$LOG_FILE"
        exit 1
    fi

    # Restore both /srv/volume and /srv/data from the latest snapshot
    echo "Restoring snapshot $LATEST_SNAPSHOT to $RESTORE_TARGET" | tee -a "$LOG_FILE"

    # Restore /srv/volume
    restic restore "$LATEST_SNAPSHOT" --repo "$RESTIC_REPOSITORY" --password-file "$RESTIC_PASSWORD_FILE" --target "$RESTORE_TARGET" --path "/srv/volume"

    # Restore /srv/data
    restic restore "$LATEST_SNAPSHOT" --repo "$RESTIC_REPOSITORY" --password-file "$RESTIC_PASSWORD_FILE" --target "$RESTORE_TARGET" --path "/srv/data"

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

# Paths to the original directories and the temporary restore location
original_dir_data="/srv/data"
restore_dir_data="/srv/restore/srv/data"
original_dir_volume="/srv/volume"
restore_dir_volume="/srv/restore/srv/volume"

# Perform a Restic check (you can skip this step if you already use it for integrity checks)
restic check

# Perform the restore operation (modify this to match your restore process)
restic restore latest --target /srv/restore

# Get the size of the original and restored directories for 'data'
original_size_data=$(du -sh "$original_dir_data" | awk '{print $1}')
restored_size_data=$(du -sh "$restore_dir_data" | awk '{print $1}')

# Get the size of the original and restored directories for 'volume'
original_size_volume=$(du -sh "$original_dir_volume" | awk '{print $1}')
restored_size_volume=$(du -sh "$restore_dir_volume" | awk '{print $1}')

# Compare the sizes for 'data'
if [ "$original_size_data" != "$restored_size_data" ]; then
    echo "Error: Restored size for 'data' does not match original size! $original_size_data != $restored_size_data"
    exit 1
else
    echo "Restored size for 'data' matches the original size."
fi

# Compare the sizes for 'volume'
if [ "$original_size_volume" != "$restored_size_volume" ]; then
    echo "Error: Restored size for 'volume' does not match original size! $original_size_volume != $restored_size_volume"
    exit 1
else
    echo "Restored size for 'volume' matches the original size."
fi

# Finish
echo "Restore completed: $(date)" | tee -a "$LOG_FILE"
