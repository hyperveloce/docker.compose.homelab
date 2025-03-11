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
   echo "{new-secure-password}" | sudo docker secret create mysql_password -
   echo "{new-secure-password}" | sudo docker secret create mysql_root_password -
   echo "{new-secure-password}" | sudo docker secret create mysql_user -
   sudo docker secret ls

3. environment setup:
   ```bash
   export USERDIR=/home/kanasu/kserver

### Backup and restore
1. initialise:
   ```bash
   sudo chmod u+w /home/kanasu/kserver/docker.backup
   sudo borg init --encryption=repokey /home/kanasu/kserver/docker.backup
- set the password
