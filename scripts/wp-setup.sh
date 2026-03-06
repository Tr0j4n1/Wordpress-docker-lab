#!/usr/bin/env bash
set -euo pipefail

WP_PATH="/var/www/html"

echo "==> Waiting for WordPress files to be ready..."
sleep 5

cd "$WP_PATH"

# ── wp-config.php ───────────────────────────────
if [ ! -f "$WP_PATH/wp-config.php" ]; then
  echo "==> Creating wp-config.php"
  wp config create \
    --dbname="${WORDPRESS_DB_NAME:-wordpress}" \
    --dbuser="${WORDPRESS_DB_USER:-wordpress}" \
    --dbpass="${WORDPRESS_DB_PASSWORD:-wordpress}" \
    --dbhost="${WORDPRESS_DB_HOST:-db:3306}" \
    --path="$WP_PATH" \
    --allow-root \
    --skip-check
fi

# ── Wait for DB ─────────────────────────────────
echo "==> Waiting for MySQL to accept queries..."
until wp db check --path="$WP_PATH" --allow-root >/dev/null 2>&1; do
  echo "   - DB not ready yet; retrying in 3s..."
  sleep 3
done
echo "   - DB is ready."

# ── Core install ────────────────────────────────
if ! wp core is-installed --path="$WP_PATH" --allow-root >/dev/null 2>&1; then
  echo "==> Running wp core install"
  wp core install \
    --url="http://localhost" \
    --title="Vuln Lab" \
    --admin_user="admin" \
    --admin_password="admin@123" \
    --admin_email="admin@example.com" \
    --path="$WP_PATH" \
    --allow-root

  # Nice defaults
  wp option update blogdescription "WordPress Vulnerability Testing Lab" --allow-root
  wp rewrite structure '/%postname%/' --hard --allow-root
fi

# ── Users ───────────────────────────────────────
create_user () {
  local USERNAME="$1"
  local PASSWORD="$2"
  local ROLE="$3"
  local EMAIL="$4"

  if wp user get "$USERNAME" --allow-root >/dev/null 2>&1; then
    echo "==> User '$USERNAME' already exists, skipping"
  else
    echo "==> Creating user '$USERNAME' with role '$ROLE'"
    wp user create "$USERNAME" "$EMAIL" --role="$ROLE" --user_pass="$PASSWORD" --allow-root
  fi
}

create_user "author"      "author@123"      "author"      "author@example.com"
create_user "editor"      "editor@123"      "editor"      "editor@example.com"
create_user "subscriber"  "subscriber@123"  "subscriber"  "subscriber@example.com"
create_user "contributor" "contributor@123" "contributor" "contributor@example.com"

# ── Debug constants ─────────────────────────────
wp config set WP_DEBUG true --raw --type=constant --allow-root 2>/dev/null || true
wp config set WP_DEBUG_LOG true --raw --type=constant --allow-root 2>/dev/null || true
wp config set WP_DEBUG_DISPLAY true --raw --type=constant --allow-root 2>/dev/null || true

# ── Summary ─────────────────────────────────────
echo ""
echo "============================================="
echo "  WordPress Vulnerability Lab is ready!"
echo "============================================="
echo ""
echo "  WordPress   : http://localhost"
echo "  WP Admin    : http://localhost/wp-admin"
echo "  phpMyAdmin  : http://localhost:8080"
echo "  Mailpit     : http://localhost:8025"
echo ""
echo "  Admin creds : admin / admin@123"
echo "  DB creds    : wordpress / wordpress  (root: root)"
echo ""
echo "  PHP version : 7.4  (XDebug enabled)"
echo "============================================="
echo ""
echo "==> Setup complete."
exit