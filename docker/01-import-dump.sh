#!/bin/bash
# Runs only when the db_data volume is empty (first boot or after docker compose down -v).
set -euo pipefail

DUMP="${DUMP_ZIP:-/dump/mafialiv_forum_database.zip}"
DB_NAME="${MARIADB_DATABASE:-mafialiv_forum}"

if [ ! -f "$DUMP" ]; then
	echo "Dump not found: $DUMP"
	exit 1
fi

if ! command -v unzip >/dev/null 2>&1; then
	apt-get update
	apt-get install -y --no-install-recommends unzip
	rm -rf /var/lib/apt/lists/*
fi

echo "Importing $DUMP into $DB_NAME..."
unzip -p "$DUMP" | mysql --force --protocol=socket -uroot "$DB_NAME"
echo "Import finished."
