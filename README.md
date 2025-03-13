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

2. pre-setup for docker:
   ```bash
   docker swarm init
   echo "{new-secure-password}" | sudo docker secret create mysql_password -
   echo "{new-secure-password}" | sudo docker secret create mysql_root_password -
   echo "{new-secure-password}" | sudo docker secret create mysql_user -
   echo "{new-secure-password}" | sudo docker secret create admin_password -
   sudo docker secret ls

3. environment setup:
   ```bash
   export USERDIR=/home/kanasu/kserver

### Backup and restore
1. setup:
   ```bash
   export RESTIC_REPOSITORY=/home/kanasu/kserver/restic.backups
   export RESTIC_PASSWORD=yourpassword
   restic init
   restic snapshots
2. backup:
   ```bash
   restic backup /srv/volume
3. restore:
   ```bash
   restic restore 4f3b9054 --target /srv/volume/nextclouddb_data_restored/
3. restore:
   ```bash
   restic forget id
   restic prune
   
- backup or restore key from proton pass
   ```bash
   cat 123123
- run backup docker-backup.sh
