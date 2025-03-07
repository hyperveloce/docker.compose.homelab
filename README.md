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
- Feature 1
- Feature 2
- Feature 3

### Technologies Used
- Language/Framework 1
- Language/Framework 2
- Database/Tool 1

---

## Installation

Follow these steps to get your development environment set up.

### Prerequisites
Make sure you have the following installed:
- [Node.js](https://nodejs.org/) (version x.x.x)
- [Docker](https://www.docker.com/)
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

   export USERDIR=/home/kanasu/kserver
