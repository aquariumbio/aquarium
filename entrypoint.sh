#!/bin/sh
set -e

# TODO: allow different name for s3 service
_fix_local_minio_ip() {
  # see https://serverfault.com/questions/551487/dnat-from-localhost-127-0-0-1
  echo "fix local"
#   S3_IP=`dig s3 +short`
#   iptables -t nat -A OUTPUT -m addrtype --src-type LOCAL --dst-type LOCAL -p tcp --dport 9000 -j DNAT --to-destination $S3_IP:9000
#   iptables -t nat -A POSTROUTING -m addrtype --src-type LOCAL --dst-type UNICAST -j MASQUERADE
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
    _clean_up_stray_server
    _wait_for_database
    echo "Starting Rails server"
    # exec puma -C config/production_puma.rb -e $1
}

_start_development_server() {
    _clean_up_stray_server
    _wait_for_database
    echo "Starting Rails server"
    # exec rails server -e $1 -p 3000 -b '0.0.0.0'
}

_add_admin_user() {
    echo "adding admin user with environment variables"
}

_build_empty_database() {
    echo "building empty database"
}

_main() {
    # ignore bundle paths
    # see https://bundler.io/v2.0/guides/bundler_docker_guide.html
    unset BUNDLE_PATH
    unset BUNDLE_BIN

    echo "Running aquarium entrypoint script with arguments: $*"

    if [[ $1 == "development" ]]; then
        _fix_local_minio_ip
        _start_development_server
    elif [[ $1 == "production" ]]; then
        if [[ $2 == "local" ]]; then
          _fix_local_minio_ip
        fi
        _start_production_server
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