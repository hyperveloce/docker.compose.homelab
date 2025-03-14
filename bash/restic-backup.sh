#!/bin/bash
#chmod +x ~/restic-backup.sh
# Config
RESTIC_REPOSITORY=/home/kanasu/kserver/restic.backups
RESTIC_PASSWORD_FILE=/home/kanasu/kserver/restic-pw.txt
LOG_FILE="/home/kanasu/kserver/restic-backup.log"

# Paths to back up
BACKUP_PATHS=(
    "/srv/data"
    "/srv/volume"
)

# Get current day (1=Monday, 7=Sunday)
DAY_OF_WEEK=$(date +%u)

# Start backup
echo "Starting backup: $(date)" | tee -a "$LOG_FILE"
restic backup "${BACKUP_PATHS[@]}" \
    --repo "$RESTIC_REPOSITORY" \
    --password-file "$RESTIC_PASSWORD_FILE" \
    --tag "weekly"

# Retention policy
if [ "$DAY_OF_WEEK" -eq 7 ]; then
    # Tag last snapshot as "monthly"
    echo "Tagging latest snapshot as monthly..." | tee -a "$LOG_FILE"
    LATEST_SNAPSHOT=$(restic snapshots --json | jq -r '.[-1].id')
    restic tag "$LATEST_SNAPSHOT" --add "monthly"

    # Prune old backups
    echo "Applying retention policy..." | tee -a "$LOG_FILE"
    restic forget \
        --keep-daily 7 \
        --keep-weekly 2 \
        --keep-quarterly 2 \
        --prune
fi

# Finish
echo "Backup completed: $(date)" | tee -a "$LOG_FILE"
