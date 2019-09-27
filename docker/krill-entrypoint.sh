#!/bin/sh
set -e

# ignore bundle paths
# see https://bundler.io/v2.0/guides/bundler_docker_guide.html
unset BUNDLE_PATH
unset BUNDLE_BIN

echo "Running krill entrypoint script with arguments: $*"

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
  S3_IP=`dig s3 +short`
  iptables -t nat -A OUTPUT -m addrtype --src-type LOCAL --dst-type LOCAL -p tcp --dport 9000 -j DNAT --to-destination $S3_IP:9000
  iptables -t nat -A POSTROUTING -m addrtype --src-type LOCAL --dst-type UNICAST -j MASQUERADE
fi

if [[ $1 == "development" || $1 == "production" ]]; then
  echo "Starting Krill runner"
  exec rails runner -e $1 'Krill::Server.new.run(3500)'
else
  # If the normal image startup flags were not given as arguments, 
  # then exec whatever arguments were given
  exec "$@"
fi