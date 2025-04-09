# Project Name

> A short description of the project goes here. What does it do? Why does it exist?

[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

## Table of Contents
- [About](#about)
- [Installation](#installation)
- [Usage](#usage)
- [Contributing](#contributing)
- [License](#license)
- [Contact](#contact)

---

## About

This section should explain what your project is about. Provide the context for why your project exists, what problem it solves, or what it's intended to do.

### Features
- Homarr dash board
- NextCloud

---

## Installation

Follow these steps to get your development environment set up.

### Prerequisites
Make sure you have the following installed:
- [Docker](https://www.docker.com/)
- [Docker-Compose](https://www.docker-compose.com/)
- Any other dependencies your project needs

### Steps

1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/project-name.git
   cd project-name
   ```

2. pre-setup for docker:
   ```bash

   ln -s /srv/data/secrets.env /home/kanasu/git.hyperveloce/docker.compose.homelab/.env

   docker swarm init
   read -s -p "Enter a new secure password: " password && echo "$password" | sudo docker secret create mysql_password -
   read -s -p "Enter a new secure password: " password && echo "$password" | sudo docker secret create mysql_root_password -
   read -s -p "Enter a new secure password: " password && echo "$password" | sudo docker secret create mysql_user -
   read -s -p "Enter a new secure password: " password && echo "$password" | sudo docker secret create admin_password -
   read -s -p "Enter a new secure password: " password && echo "$password" | sudo docker secret create cloudflare_token -
   sudo docker secret ls
   ```

3. environment setup:
   ```bash
   echo 'USERDIR=/home/kanasu/kserver' | sudo tee -a /etc/environment
   read -s -p "Enter a new secure password: " password && echo "$password" | sudo tee /home/kanasu/kserver/restic-pw.txt > /dev/null
   ```

### Nextcloud optimum config
1. change below param for NextCloud container:
   PHP_UPLOAD_MAX_SIZE: 5G
   PHP_MEMORY_LIMIT: 1024M
   APC_SHM_SIZE: 256M
   OPCACHE_MEM_SIZE: 256M
   CRON_PERIOD: 10m
   MEMCACHE_LOCAL: '\OC\Memcache\Redis' # Tells Nextcloud to use Redis for local caching
   ```
2. Setup the following param for proxy
  ```bash
  proxy_set_header Host $host;
  proxy_set_header X-Real-IP $remote_addr;
  proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
  proxy_set_header X-Forwarded-Proto https;
  proxy_set_header X-Frame-Options SAMEORIGIN;
  proxy_hide_header X-Powered-By;
  ```
  2. Setup the following param for proxy
  ```bash
  'trusted_proxies' => ['172.21.0.7'],
  'overwriteprotocol' => 'https',
  'trusted_domains' =>
  array (
    0 => '192.168.50.201:8080',
    1 => 'dna-nc.duckdns.org',
  ),
  ```
### Backup and restore
1. environment setup:
   ```bash
   read -s -p "Enter a new secure password: " password && echo "$password" | sudo tee /home/kanasu/kserver/restic-pw.txt > /dev/null
   echo 'RESTIC_REPOSITORY=/home/kanasu/kserver/restic.backups"' | sudo tee -a /etc/environment
   echo 'RESTIC_PASSWORD_FILE=/home/kanasu/kserver/restic-pw.txt' | sudo tee -a /etc/environment
   ```

2. backup setup:
    ```bash
   restic init
   restic snapshots
   ```

2. execute backup:
   ```bash
   sudo chmod -R 770 /srv/
   restic backup /srv/data
   restic backup /srv/volume
   restic snapshots
   ```

3. execute restore:
   ```bash
   restic restore latest --target /srv/restore --include /srv/data
   ```

3. cleanup:
   ```bash
   restic snapshots
   restic forget id
   restic prune
   ```

### Cert Setup

1. Clone the repository:
   ```bash
   sudo apt install mkcert
   mkcert kserver.dna
   ```
### Cert Setup

2. Router dhcp and dns:
   ```bash
   service restart_dnsmasq
   service restart_dhcpd
   ```

### NextCloud manual update
1. Clone the repository:
   ```bash
   sudo docker exec --user www-data -it nextcloud php occ upgrade
   ```

### Home Assistant setup
1. Clone the repository:
   ```
   http:
     use_x_forwarded_for: true
     trusted_proxies:
       - 172.21.0.18
   ```
  https://medium.com/@life-is-short-so-enjoy-it/homeassistant-reverse-proxy-with-nginx-two-issues-i-faced-c7772ad0446c

   ```bash
   docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' nginx_pm
   ```
