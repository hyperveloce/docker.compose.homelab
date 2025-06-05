#!/bin/bash
#chmod +x restic-backup.sh

# Config
RESTIC_PASSWORD_FILE=/home/kanasu/kserver/restic-pw.txt
LOG_FILE="/home/kanasu/kserver/restic-backup.log"

# Paths to back up
BACKUP_PATHS=(
    "/srv/data"
    "/srv/volume"
)

# Backup repositories (you can add multiple repositories here)
BACKUP_REPOSITORIES=(
    # "/home/kanasu/kserver/restic.backups"
    "/mnt/asus/kserver_backup/restic-backups"
    # "/mnt/offsite_nas/restic-backups"
)

# Get current day (1=Monday, 7=Sunday)
DAY_OF_WEEK=$(date +%u)

# Start backup
echo "Starting backup: $(date)" | tee -a "$LOG_FILE"

# Loop through repositories and perform backups
for REPO in "${BACKUP_REPOSITORIES[@]}"; do
    echo "Backing up to repository: $REPO" | tee -a "$LOG_FILE"
    restic backup "${BACKUP_PATHS[@]}" \
        --repo "$REPO" \
        --password-file "$RESTIC_PASSWORD_FILE"
done

# Retention policy for local backup repositories
if [ "$DAY_OF_WEEK" -eq 7 ]; then
    echo "Applying local retention policy..." | tee -a "$LOG_FILE"
    for REPO in "${BACKUP_REPOSITORIES[@]}"; do
        if [ "$REPO" != "/mnt/offsite_nas/restic-backups" ]; then
            # Apply retention for local and network backups
            echo "Pruning local or network backup: $REPO" | tee -a "$LOG_FILE"
            restic forget \
                --repo "$REPO" \
                --keep-daily 7 \
                --keep-weekly 2 \
                --keep-quarterly 2 \
                --prune
        fi
    done

    # Retention policy for offsite NAS repository
    echo "Applying offsite retention policy..." | tee -a "$LOG_FILE"
    restic forget \
        --repo "/mnt/offsite_nas/restic-backups" \
        --keep-weekly 2 \
        --keep-quarterly 2 \
        --prune
fi

# Finish
echo "Backup completed: $(date)" | tee -a "$LOG_FILE"
