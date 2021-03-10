#!/bin/bash
set -uxo pipefail

docker-compose -f docker-compose.yml -f docker-compose.test-db.yml -f docker-compose.test.yml $@