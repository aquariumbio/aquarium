#!/bin/bash
set -uxo pipefail

if [[ $# -ne 2 ]]; then
    echo "Expected 2 arguments: environment database-file"
    exit 2
fi

ENV_DIR=.env_files/$1
USER=`perl -lne '/^DB_USER=(.*)/ && print "$1"' $ENV_DIR/backend`
PASSWORD=`perl -lne '/^DB_PASSWORD=(.*)/ && print "$1"' $ENV_DIR/backend`
DATABASE=`perl -lne '/^DB_NAME=(.*)/ && print "$1"' $ENV_DIR/backend`

cat $2 | docker-compose exec -T db mysql -u "$USER" -p"$PASSWORD" "$DATABASE"
