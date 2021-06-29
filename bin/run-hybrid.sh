#!/bin/sh
docker-compose -f docker-compose.yml -f docker-compose.production.yml -f docker-compose.v2-production.yml -f docker-compose.s3-production.yml $@
