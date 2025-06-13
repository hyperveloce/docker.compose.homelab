#!/bin/bash

# Config
RESTIC_REPO="/mnt/asus/kserver_backup/restic-backups"
RESTORE_DIR="$HOME/restic-restore-test"
SNAPSHOT_ID="b7e37243"
LOG_FILE="/srv/restic-restore.log"
ENV_FILE="$HOME/git.hyperveloce/docker.compose.homelab/.env"

# Load environment variables (expects RESTIC_PASSWORD)
set -a
source "$ENV_FILE"
set +a

# Check if password is set
if [ -z "$RESTIC_PASSWORD" ]; then
    echo "❌ RESTIC_PASSWORD not loaded. Check $ENV_FILE" | tee -a "$LOG_FILE"
    exit 1
fi

echo "🔄 Starting restore of snapshot $SNAPSHOT_ID to $RESTORE_DIR: $(date)" | tee -a "$LOG_FILE"

# Create restore directory if it doesn't exist
mkdir -p "$RESTORE_DIR"

# Run restore
restic restore "$SNAPSHOT_ID" \
    --target "$RESTORE_DIR" \
    --repo "$RESTIC_REPO" \
    2>&1 | tee -a "$LOG_FILE"

# Check exit status
if [ "${PIPESTATUS[0]}" -ne 0 ]; then
    echo "❌ Restore failed: $(date)" | tee -a "$LOG_FILE"
    exit 1
fi

echo "✅ Restore completed successfully: $(date)" | tee -a "$LOG_FILE"
