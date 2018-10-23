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

if [[ $1 == "web" || $1 == "krill" ]] && [[ $2 == "development" || $2 == "production" ]]; then
  # If container is run without exactly 2 arguments then start server

  if [[ $2 == "production" ]]; then
    # production server must have assets precompiled 
    # ALSO SEE application.rb lines 8:13
    export RAILS_ENV="production"
    echo "precompiling assets"
    exec bundle exec rake assets:precompile
  elif [[ $2 == "development" ]]; then
    export RAILS_ENV="development"
    export AWS_ACCESS_KEY_ID="THE_DUMMY_ACCESS_KEY_ID" 
    export AWS_SECRET_ACCESS_KEY="THE_DUMMY_ACCESS_KEY" 
    export AWS_REGION="us-west-1"
    export INSTANCE_NAME="LOCAL"
    export DEBUG_TOOLS="true"
  else 
    echo "incoherent argument 2"
    exit 1
  fi

  # depending on which service is being started, use the correct respective rails command
  if [[ $1 == "web" ]]; then
    echo "Starting Rails server"
    exec bundle exec rails server -p 3000 -b '0.0.0.0'
  elif [[ $1 ==  "krill" ]]; then
    echo "Starting Krill runner"
    exec bundle exec rails runner 'Krill::Server.new.run(3500)'
  else
    echo "incoherent argument 1"
    exit 1
  fi

else
  # If the normal image startup flags were not given as arguments, 
  # then exec whatever arguments were given
  exec "$@"
fi