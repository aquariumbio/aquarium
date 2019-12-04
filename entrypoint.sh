#!/bin/sh
set -e

# entrypoint for Aquarium Docker. 
# Can be used for starting either Aquarium or Krill.
#
# Start Aquarium with one of the following commands in the docker-compose file:
# - ["production"]
# - ["production", "local"]
# - ["development"]
# "production" and "development" indicate the Rails environment, and "local"
# indicates that Aquarium is using a local minio service for S3, meaning the
# IP table needs to be modified.
# The "local" command is assumed for development mode.
#
# Start Krill with one of the following commands in the docker-compose file:
# - ["krill", "production"]
# - ["krill", "production", "local"]
# - ["krill", "development"]
# - ["krill", "development", "local"]
# which are similar to the commands for Aquarium.

# ignore bundle paths
# see https://bundler.io/v2.0/guides/bundler_docker_guide.html
unset BUNDLE_PATH
unset BUNDLE_BIN

# TODO: allow different name for s3 service
_fix_local_minio_ip() {
  # see https://serverfault.com/questions/551487/dnat-from-localhost-127-0-0-1
  echo "fix ip address for local s3"
  S3_IP=`dig s3 +short`
  iptables -t nat -A OUTPUT -m addrtype --src-type LOCAL --dst-type LOCAL -p tcp --dport 9000 -j DNAT --to-destination $S3_IP:9000
  iptables -t nat -A POSTROUTING -m addrtype --src-type LOCAL --dst-type UNICAST -j MASQUERADE
}

_wait_for_database() {
    # wait for mysql to start
    while ! nc -z $DB_HOST $DB_PORT; do
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

_start_production_server() {
    echo "Starting production Rails server"
    exec puma -C config/production_puma.rb -e production
}

_start_development_server() {
    echo "Starting development Rails server"
    exec rails server -e development -p 3000 -b '0.0.0.0'
}

_start_krill_server() {
    echo "Starting $1 Krill runner"
    exec rails runner -e $1 'Krill::Server.new.run(3500)'
}

_add_admin_user() {
    echo "adding admin user with environment variables"
}

_build_empty_database() {
    echo "building empty database"
}

_main() {
    echo "Running aquarium entrypoint script with arguments: $*"

    _clean_up_stray_server
    _wait_for_database

    if [[ $1 == "development" ]]; then
        _fix_local_minio_ip
        _start_development_server
    elif [[ $1 == "production" ]]; then
        if [[ $2 == "local" ]]; then
          _fix_local_minio_ip
        fi
        _start_production_server
    elif [[ $1 == "krill" ]]; then
        if [[ $3 == "local" ]]; then
          _fix_local_minio_ip
        fi
        _start_krill_server $2
    else
        # If the normal image startup flags were not given as arguments, 
        # then exec whatever arguments were given
        exec "$@"
    fi
}

# Run _main unless sourced
if [ ${0##*/} != 'sh' ]; then
    echo "running"
  _main "$@"
fi