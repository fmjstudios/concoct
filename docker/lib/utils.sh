# shellcheck shell=bash

# logging
log() {
  echo "[$(date '+%d-%m-%Y_%T')] $(basename "${0}"): ${*}"
}

# install Composer dependencies
install_dependencies() {
  # Install deps if vendor directory is empty
  if [ -z "$(ls -A 'vendor/' 2>/dev/null)" ]; then
    log "Installing concoct PHP Composer dependencies!"
    composer install --prefer-dist --no-progress --no-interaction
    return 0
  fi

  # continue if it isn't
  log "Dependencies are installed: 'vendor' directory exists!"
  return 0
}

# Check for a database connection or correct permissions
database_check() {
  echo "|--------------------------------------------------------------|"
  echo "|             Checking for an available database!              |"
  echo "|--------------------------------------------------------------|"

  # DATABASE_URL is for remote DB, otherwise the write permissions for SQLite in ./var
  if grep -Eq '^DATABASE_URL="mysql|postgresql' .env || [ -n "${DATABASE_URL}" ]; then
    try_database_connection
  else
    sqlite3 var/app.db <<EOF
.exit
EOF
  fi

  # apply migrations if there are any
  if [ "$(find ./migrations -iname '*.php' -print -quit)" ]; then
    php bin/console doctrine:migrations:migrate --no-interaction --all-or-nothing
  fi

  log "Migrations have been applied."
}

# Try to connect to the database within the timeout
try_database_connection() {
  local tries
  tries=0

  # define Timeout if unset
  if [ -z "$DATABASE_TIMEOUT" ]; then
    DATABASE_TIMEOUT=120
    tries="$DATABASE_TIMEOUT"
  else
    tries="$DATABASE_TIMEOUT"
  fi

  log "Waiting for database to be ready..."
  until [ "$tries" -eq 0 ] || DATABASE_ERROR=$(php bin/console dbal:run-sql -q "SELECT 1" 2>&1); do
    if [ $? -eq 255 ]; then
      # If the Doctrine command exits with 255, an unrecoverable error occurred
      tries=0
      break
    fi

    sleep 1
    tries=$((tries + 1))
    log "Still waiting for database to become available... Waiting $((DATABASE_TIMEOUT - tries)) more seconds to connection!"
  done

  # depleted our tries
  if [ "${tries}" -eq "${DATABASE_TIMEOUT}" ]; then
    log "FATAL: Could not connect to database within timeout of ${tries} seconds. Exiting."
    log "ERROR: ${DATABASE_ERROR}"
    exit 1
  fi

  log "Database is ready and reachable."
}
