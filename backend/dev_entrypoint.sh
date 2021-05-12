#!/bin/sh
set -euxo pipefail

# development entrypoint for Aquarium Docker.
#
# Start Aquarium in development mode by giving the command "development".
# Alternatively, give a shell command to run in the Aquarium container
#

# ignore bundle paths
# see https://bundler.io/v2.0/guides/bundler_docker_guide.html
unset BUNDLE_PATH
unset BUNDLE_BIN

# Wait for database to start.
_wait_for_database() {
    echo "waiting for database to respond"
    while ! nc -z ${DB_HOST:-'db'} ${DB_PORT:-3306}; do
        sleep 1 # wait for 1 second before check again
    done
}

_clean_up_stray_server() {
    # see https://stackoverflow.com/questions/35022428/rails-server-is-still-running-in-a-new-opened-docker-container/38732187#38732187
    if [ -f tmp/pids/server.pid ]; then
        echo "Removing stray server.pid"
        rm tmp/pids/server.pid
    fi
}

# Starts the develoment server.
_start_development_server() {
    echo "Starting development Rails server"
    rails db:migrate RAILS_ENV=development
    exec rails server -e development -p 3000 -b '0.0.0.0'
}

# Starts server with test environment for end-to-end testing
_start_test_server() {
    echo "Starting test Rails server"
    rails db:environment:set RAILS_ENV=test
    rails db:structure:load RAILS_ENV=test
    rails db:seed:test_seeds RAILS_ENV=test
    exec rails server -e test -p 3000 -b '0.0.0.0'
}

_main() {
    echo "Running aquarium entrypoint script with arguments: $*"

    _clean_up_stray_server
    _wait_for_database

    if [ $1 = "development" ]; then
        _start_development_server
    elif [ $1 = "test" ]; then
        _start_test_server
    else
        # If the normal image startup flags were not given as arguments,
        # then exec whatever arguments were given
        exec "$@"
    fi
}

# Run _main unless sourced
if [ ${0##*/} != 'sh' ]; then
  _main "$@"
fi
