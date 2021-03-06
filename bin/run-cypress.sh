#!/bin/bash
set -uxo pipefail

docker-compose -f docker-compose.test.yml -f docker-compose.cypress.yml up --exit-code-from e2e
