#!/bin/bash
set -uxo pipefail

if [[ $# -ne 2 ]]; then
    echo "Expected 2 arguments: environment database-name"
    exit 2
fi

ENV_DIR=.env/$1

# Replace value for database name in each of the db and backend files
env VALUE=$2 perl -i -lpe 's/DB_NAME=\K.*/$ENV{VALUE}/' $ENV_DIR/backend
env VALUE=$2 perl -i -lpe 's/MYSQL_DATABASE=\K.*/$ENV{VALUE}/' $ENV_DIR/db
