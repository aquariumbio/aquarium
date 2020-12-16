#!/bin/bash
set -uxo pipefail

docker-compose -f docker-compose.yml -f docker-compose.override.yml -f docker-compose.cypress.yml -f docker-compose.cypress-open.yml up --exit-code-from e2e