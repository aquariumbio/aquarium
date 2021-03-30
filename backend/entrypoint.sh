#!/bin/sh
set -euxo pipefail

# production entrypoint

# ignore bundle paths
# see https://bundler.io/v2.0/guides/bundler_docker_guide.html
unset BUNDLE_PATH
unset BUNDLE_BIN

# Add AWS ECS local domain to container resolv.conf
# See https://github.com/docker/ecs-plugin
#
_add_ecs_namespace() {
    if [ "${LOCALDOMAIN}" != ""  ]; then
        echo "Adding ECS local domain to resolv.conf"
        echo "search ${LOCALDOMAIN}" >> /etc/resolv.conf
    fi
}

_clean_up_stray_server() {
    # see https://stackoverflow.com/questions/35022428/rails-server-is-still-running-in-a-new-opened-docker-container/38732187#38732187
    if [ -f tmp/pids/server.pid ]; then
        echo "Removing stray server.pid"
        rm tmp/pids/server.pid
    fi
}

# Folds the license file into 80 columns, strips off the markdown header, and
# sends the result to standard output.
_show_license() {
    if [ -f LICENSE ]; then
        fold -w 80 -s LICENSE | tail -n +3
    else
        echo "LICENSE file not found. Please report."
    fi
}

_start_production_server() {
    echo "Starting production Rails server"
    _add_ecs_namespace()
    _show_license()
    # exec
}

# Wait for database to start.
_wait_for_database() {
    echo "waiting for database to respond"
    while ! nc -z ${DB_HOST:-'db'} ${DB_PORT:-3306}; do
        sleep 1 # wait for 1 second before check again
    done
}

_main() {
    echo "Running backend entrypoint script with arguments: $*"

    _clean_up_stray_server
    _wait_for_database

    if [ $1 = "production" ]; then
        _start_production_server
    else
        exec "$@"
    fi
}

# Run _main unless sourced
if [ ${0##*/} != 'sh' ]; then
  _main "$@"
fi