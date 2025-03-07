#!/bin/bash
#chmod +x docker-compose_library.sh
#./docker-compose_library.sh

echo "Docker Compose Command Library"
echo "1. Start Services"
echo "2. Stop Services"
echo "3. View Logs"
echo "4. Run Backup"
echo "5. Run Restore"
echo "6. Check Service Status"
echo "7. Exit"

read -p "Choose a command (1-7): " choice

case $choice in
  1)
    echo "Starting services..."
    docker-compose up -d
    ;;
  2)
    echo "Stopping services..."
    docker-compose down
    ;;
  3)
    echo "Viewing logs..."
    docker-compose logs -f
    ;;
  31)
    echo "Pull latest images..."
    docker-compose pull
    ;;
  4)
    echo "Running backup..."
    docker-compose run backup
    ;;
  5)
    echo "Running restore..."
    docker-compose run restore
    ;;
  6)
    echo "Checking service status..."
    docker-compose ps
    ;;
  7)
    echo "logs..."
    docker-compose logs nextcloud
    ;;
  8)
    echo "Exiting..."
    docker system prune -f; docker volume prune -f; docker image prune -f
    ;;
  9)
    echo "Optimise DB..."
    docker exec -it nextcloud_db mysqlcheck -u nextcloud_user -p nextcloud
    ;;
  0)
    echo "Exiting..."
    exit 0
    ;;
  *)
    echo "Invalid choice. Please select a number between 1-7."
    ;;
esac



#setup a crhonjob for the below
#0 0 * * * docker-compose run backup

#docker run --rm --volumes-from nextcloud -v $(pwd):/backup ubuntu tar czf /backup/nextcloud_backup.tar.gz /var/www/html

#docker secret
#echo "your-mysql-password" | docker secret create mysql_password -
#echo "your-root-password" | docker secret create mysql_root_password -
#echo "your-mysql-user" | docker secret create mysql_user -
