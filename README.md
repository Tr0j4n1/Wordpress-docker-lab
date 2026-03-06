# WordPress Docker Lab

A fully automated Docker Compose environment for WordPress vulnerability research, plugin testing, and PoC development.

Built for **local security research only** — features PHP 7.4 (for string deserialization viability), XDebug step-through debugging, phpMyAdmin, Mailpit, and automated multi-role user creation.

---

## Features

| Feature | Detail |
|---|---|
| **PHP 7.4 + XDebug** | Custom-built image — deserialization vulns viable; step-through debugging on port 9003 |
| **Automated Setup** | WP core install + 5 users (admin, author, editor, subscriber, contributor) — zero manual config |
| **phpMyAdmin** | Full DB admin UI at `:8080` |
| **Mailpit** | Catches all outgoing email — web UI at `:8025` |
| **FPM + Nginx Variant** | Secondary compose file for Nginx-proxied testing (IP spoofing via `X-Forwarded-For`) |
| **Makefile** | One-command operations: `make up`, `make down`, `make shell`, etc. |
| **MySQL 8.0** | With healthcheck — WP-CLI waits for DB readiness |
| **VSCode Debug Config** | XDebug launch config included |

---

## Directory Structure

```text
.
├── Makefile                    # Shortcuts for common operations
├── docker-compose.yml          # Primary stack (Apache + PHP 7.4 + XDebug)
├── docker-compose.fpm.yml      # FPM + Nginx variant
├── xdebug/
│   ├── Dockerfile              # WordPress PHP 7.4 + XDebug build
│   ├── files-to-copy/          # php.ini + xdebug.ini
│   └── README.md
├── wp/
│   └── .htaccess               # WordPress rewrite stub
├── scripts/
│   └── wp-setup.sh             # Automated WP install + user creation
├── nginx/
│   └── conf.d/
│       └── default.conf        # Nginx config (FPM variant only)
└── .vscode/
    └── launch.json             # XDebug listen config
```

---

## Requirements

- [Docker Desktop](https://www.docker.com/products/docker-desktop/) (or Docker Engine + Docker Compose v2)
- `make` (optional, for Makefile shortcuts)

---

## Quick Start

```bash
git clone https://github.com/Tr0j4n1/Wordpress-docker-lab.git
cd Wordpress-docker-lab

make build   # Build the custom WordPress+XDebug image
make up      # Start all containers
```

Or without `make`:

```bash
docker-compose build
docker-compose up -d
```

---

## Endpoints

| Service | URL |
|---|---|
| WordPress | http://localhost |
| WP Admin | http://localhost/wp-admin |
| phpMyAdmin | http://localhost:8080 |
| Mailpit | http://localhost:8025 |

---

## Credentials

### WordPress Users

| Username | Password | Role |
|---|---|---|
| admin | admin@123 | Administrator |
| author | author@123 | Author |
| editor | editor@123 | Editor |
| subscriber | subscriber@123 | Subscriber |
| contributor | contributor@123 | Contributor |

### Database

| User | Password |
|---|---|
| root | root |
| wordpress | wordpress |

---

## Make Commands

```
make build       Build the WordPress+XDebug image
make up          Start the stack
make down        Stop and remove containers
make restart     Restart the stack
make logs        Tail logs for all services
make ps          Show running containers
make shell       Open bash shell in WordPress container
make db-shell    Open MySQL shell
make reset       Nuke everything (containers + volumes)
make wp CMD="…"  Run any WP-CLI command
make fpm-up      Start the FPM+Nginx variant
make fpm-down    Stop the FPM+Nginx variant
```

---

## FPM + Nginx Variant

For testing scenarios that require Nginx (e.g., IP spoofing via `X-Forwarded-For`):

```bash
make fpm-up      # or: docker-compose -f docker-compose.fpm.yml up -d
```

The Nginx config at `nginx/conf.d/default.conf` deliberately trusts `X-Forwarded-For` headers — useful for IP-based access control bypass demos.

---

## Reset Environment

```bash
make reset       # or: docker-compose down -v
make up
```

Useful when:
- Retesting a vulnerability from scratch
- Installing a different plugin version
- Reproducing a clean PoC environment

---

## XDebug (VSCode)

1. Install the [PHP Debug](https://marketplace.visualstudio.com/items?itemName=xdebug.php-debug) extension
2. Open this project in VSCode — `.vscode/launch.json` is pre-configured
3. Start "Listen for XDebug" from the Run panel
4. Set breakpoints in `wp/` — XDebug connects automatically on every request

---

## Why PHP 7.4?

PHP 7.4 is intentionally used because **string deserialization vulnerabilities** (e.g., `unserialize()` exploits) are viable on it. These same vulnerabilities may **not work on PHP 8+** due to stricter type handling. This makes the lab ideal for testing WordPress plugin deserialization chains.

---

## Disclaimer

This lab is intended for **authorized security research and local testing only**. Do not expose it to the internet. All credentials are intentionally weak for ease of testing.
