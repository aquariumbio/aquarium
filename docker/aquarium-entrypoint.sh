#!/bin/sh
set -e

# ignore bundle paths
# see https://bundler.io/v2.0/guides/bundler_docker_guide.html
unset BUNDLE_PATH
unset BUNDLE_BIN

echo "Running aquarium entrypoint script with arguments: $*"

# see https://stackoverflow.com/questions/35022428/rails-server-is-still-running-in-a-new-opened-docker-container/38732187#38732187
if [ -f tmp/pids/server.pid ]; then
  echo "Removing stray server.pid"
  rm tmp/pids/server.pid
fi

# wait for mysql to start
while ! nc -z db 3306; do
  sleep 1 # wait for 1 second before check again
done


if [[ $1 == "production" || $1 == "development" ]]; then
  # see https://serverfault.com/questions/551487/dnat-from-localhost-127-0-0-1

  S3_IP=`dig s3 +short`
  iptables -t nat -A OUTPUT -m addrtype --src-type LOCAL --dst-type LOCAL -p tcp --dport 9000 -j DNAT --to-destination $S3_IP:9000
  iptables -t nat -A POSTROUTING -m addrtype --src-type LOCAL --dst-type UNICAST -j MASQUERADE
fi

if [[ $1 == "development" ]]; then
  echo "Starting Rails server"
  exec rails server -e $1 -p 3000 -b '0.0.0.0'
elif [[ $1 == "production" ]]; then
  # Production server must have assets precompiled
  # Note only works once db is up (e.g., can't be done in Dockerfile)
  # ALSO SEE application.rb lines 8:13
  # TODO: figure out why precompiling requires database and must be done here
  echo "Precompiling assets"
  RAILS_ENV=production
  
  rake assets:precompile
  echo "Starting Rails server"
  exec puma -C config/production_puma.rb -e $1
else
  # If the normal image startup flags were not given as arguments, 
  # then exec whatever arguments were given
  exec "$@"
fi