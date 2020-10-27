#!/bin/sh
set -euxo pipefail

# entrypoint for Aquarium Docker. 
# Can be used for starting either Aquarium or Krill.
#
# Start Aquarium with one of the following commands in the docker-compose file:
# - ["production"]
# - ["development"]
# where "production" and "development" indicate the Rails environment.
#
# Start Krill with one of the following commands in the docker-compose file:
# - ["krill", "production"]
# - ["krill", "development"]
#
# The script also checks the value of the environment variable $S3_HOST.
# If this value begins with `localhost`, the script assumes a local configuration
# using minio for a service named s3.
# This configuration requires that the IP table be modified.

# ignore bundle paths
# see https://bundler.io/v2.0/guides/bundler_docker_guide.html
unset BUNDLE_PATH
unset BUNDLE_BIN

# Fixes ip address for using a minio service from within the
# local docker-compose configuration.  In this case, paperclip needs the minio
# host name to be localhost:9000, and we have to force that address to point to
# the minio s3 service.
#
# This will apply fix if one of the following is true:
# - S3_LOCAL is set, 
# - S3_HOST is not set, or
# - S3_HOST is set to localhost:9000.
_fix_local_minio_ip() {
    echo "Fixing IP address for local minio"
    # TODO: should not happen if S3_SERVICE is AWS
    if [ ! -z ${S3_LOCAL+x} ] || [ -z ${S3_HOST+x} ] || [ $(expr "$S3_HOST" : 'localhost.*') -gt 0 ]; then
        # see https://serverfault.com/questions/551487/dnat-from-localhost-127-0-0-1
        echo "fix ip address for local s3"
        S3_IP=`dig s3 +short`
        iptables -t nat -A OUTPUT -m addrtype --src-type LOCAL --dst-type LOCAL -p tcp --dport 9000 -j DNAT --to-destination $S3_IP:9000
        iptables -t nat -A OUTPUT -m addrtype --src-type LOCAL --dst-type LOCAL -p tcp --dport 80 -j DNAT --to-destination $S3_IP:9000
        iptables -t nat -A POSTROUTING -m addrtype --src-type LOCAL --dst-type UNICAST -j MASQUERADE
    fi
}

# Add AWS ECS local domain to container resolv.conf
# See https://github.com/docker/ecs-plugin
#
_add_ecs_namespace() {
    if [ "${LOCALDOMAIN}" != ""  ]; then
        echo "Adding ECS local domain to resolv.conf"
        echo "search ${LOCALDOMAIN}" >> /etc/resolv.conf
    fi
}

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

# Folds the license file into 80 columns, strips off the markdown header, and
# sends the result to standard output.
_show_license() {
    if [ -f LICENSE ]; then
        fold -w 80 -s LICENSE | tail -n +3
    else
        echo "LICENSE file not found. Please report."
    fi
}

# Starts the production server.
# First fixes the local IP address for minio if needed, and shows the license.
_start_production_server() {
    _fix_local_minio_ip
    _add_ecs_namespace()
    echo "Starting production Rails server"
    _show_license
    exec puma -C config/production_puma.rb -e production
}

# Starts the production server.
# First, fixes the local IP address for minio if needed.
_start_development_server() {
    _fix_local_minio_ip
    echo "Starting development Rails server"
    exec rails server -e development -p 3000 -b '0.0.0.0'
}

# Starts the krill server using the rails environment passed as an argument.
_start_krill_server() {
    _add_ecs_namespace()
    echo "Starting $1 Krill runner"
    exec rails runner -e $1 "Krill::Server.new.run(${KRILL_PORT:-3500})"
}


_add_admin_user() {
    echo "adding admin user with environment variables"
}

_build_empty_database() {
    echo "building empty database"
}

_update_database() {
    rake db:migrate
}

_main() {
    echo "Running aquarium entrypoint script with arguments: $*"

    _clean_up_stray_server
    _wait_for_database

    if [ $1 = "development" ]; then
        _start_development_server
    elif [ $1 = "production" ]; then
        _start_production_server
    elif [ $1 = "krill" ]; then
        _start_krill_server $2
    elif [ $1 = "update" ]; then
        _update_database
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