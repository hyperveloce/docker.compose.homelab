#!/bin/bash
# chmod +x update-docker.sh

# Set the path to your Docker Compose files
DOCKER_COMPOSE_DIR="/home/kanasu/git.hyperveloce/dockers"
LOG_FILE="/var/log/docker_update.log"

# Timestamp function
timestamp() {
    date +"%Y-%m-%d %H:%M:%S"
}

# Logging function
log() {
    echo "$(timestamp) - $1" | tee -a "$LOG_FILE"
}

# Navigate to the Docker Compose directory
cd "$DOCKER_COMPOSE_DIR" || { log "Failed to navigate to $DOCKER_COMPOSE_DIR"; exit 1; }

log "Starting Docker container updates..."

# Pull the latest images
log "Pulling the latest images..."
docker compose pull

# Recreate containers with updated images
log "Recreating containers..."
docker compose up -d --remove-orphans

# Remove old images and containers
log "Cleaning up old images and containers..."
docker system prune -af --volumes

log "Docker update and cleanup completed."

exit 0
