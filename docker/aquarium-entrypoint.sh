#!/bin/sh
set -e

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

if [[ $1 == "development" ]]; then
  echo "Starting Rails server"
  exec bundle exec rails server -e $1 -p 3000 -b '0.0.0.0'
elif [[ $1 == "production" ]]; then
  # production server must have assets precompiled 
  # ALSO SEE application.rb lines 8:13
  echo "precompiling assets"
  exec bundle exec rake assets:precompile

  exec bundle exec puma -C config/puma.rb 
else
  # If the normal image startup flags were not given as arguments, 
  # then exec whatever arguments were given
  exec "$@"
fi