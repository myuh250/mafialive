#!/bin/bash
set -euo pipefail

DB_HOST="${XF_DB_HOST:-localhost}"
DB_PORT="${XF_DB_PORT:-3306}"
DB_USER="${XF_DB_USER:-mafialiv1}"
DB_PASS="${XF_DB_PASSWORD:-kS6eIYnSlKArdFy}"
DB_NAME="${XF_DB_NAME:-mafialiv_forum}"
export MYSQL_PWD="$DB_PASS"

echo "Waiting for MariaDB at ${DB_HOST}:${DB_PORT}..."
for i in $(seq 1 60); do
    if mysqladmin ping -h "$DB_HOST" -P "$DB_PORT" -u "$DB_USER" --silent; then
        break
    fi
    if [ "$i" -eq 60 ]; then
        echo "MariaDB did not become ready in time."
        exit 1
    fi
    sleep 2
done

echo "Waiting for forum tables..."
for i in $(seq 1 180); do
    tables="$(mysql -h "$DB_HOST" -P "$DB_PORT" -u "$DB_USER" "$DB_NAME" -N -e "SHOW TABLES LIKE 'xf_user';" || true)"
    if [ -n "$tables" ]; then
        break
    fi
    if [ "$i" -eq 180 ]; then
        echo "Forum dump did not finish importing in time."
        exit 1
    fi
    sleep 2
done

unset MYSQL_PWD

exec "$@"
