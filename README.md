# Wordpress-docker-lab

Automated Docker Compose setup for quickly deploying a WordPress environment, tailored for plugin testing and security research.

This lab is intended for **local testing only** and focuses on speed, reproducibility, and ease of resetting the environment during vulnerability research.

---

## Features
- Nginx + PHP-FPM based setup
- Automated WordPress installation
- Scripted setup for fast environment resets
- Minimal and transparent configuration
- Suitable for plugin testing, PoC development, and CVE research

---

## Directory Structure.
├── docker-compose.yml
├── nginx
│   └── conf.d
│       └── default.conf
└── scripts
    └── wp-setup.sh

- `docker-compose.yml` – Orchestrates WordPress, database, and Nginx
- `default.conf` – Nginx configuration used by the container
- `wp-setup.sh` – Automates WordPress setup inside the container

---

## Requirements
- Docker
- Docker Compose (v2)

---

## Quick Start

1. Clone the repository:
   ```bash
   git clone <repo-url>
   cd wordpress-docker-lab
2. Start the environement:
   ```bash
   docker compose up -d
3. Access WordPress:
   Frontend: http://localhost
   Admin panel: http://localhost/wp-admin

Credentials and database configuration are defined directly in the Docker Compose setup for simplicity and rapid testing.

## Reset Environment
To completely reset the lab (including database and volumes):
```bash
docker compose down -v
docker compose up -d
```

This is useful when:
- Retesting a vulnerability
- Installing a different plugin version
- Reproducing a clean PoC environment
