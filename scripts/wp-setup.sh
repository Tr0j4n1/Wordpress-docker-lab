#!/usr/bin/env bash
set -euo pipefail

WP_PATH="/var/www/html"

echo "==> Waiting a bit for WordPress files to be ready..."
# tiny pause to ensure /var/www/html has been populated by the wordpress container
sleep 5

cd "$WP_PATH"

# Create wp-config.php if missing
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

# Install core if not installed
if ! wp core is-installed --path="$WP_PATH" --allow-root >/dev/null 2>&1; then
  echo "==> Running wp core install"
  wp core install \
    --url="http://localhost" \
    --title="Local WP" \
    --admin_user="admin" \
    --admin_password="admin@123" \
    --admin_email="admin@example.com" \
    --path="$WP_PATH" \
    --allow-root

  # Nice defaults
  wp option update blogdescription "Just another local WordPress" --allow-root
  wp rewrite structure '/%postname%/' --hard --allow-root
fi

# Create additional users (idempotent)
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

echo "==> Setup complete."
exit