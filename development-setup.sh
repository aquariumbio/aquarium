#!/bin/bash

# This script places default development config files in the correct places, 
# preparing the environment for a development docker aquarium instance.


# Optionally: start from a fresh database. This will not work when done from the docker toolbox VM.
# For this case, you can instead manually delete the files from the windows file explorer.
# sudo rm -rf docker/db/*       


if [[ $1 == "windows" ]]; then
    cp docker/windev-docker-compose.yml docker-compose.yml
else
    cp docker/dev-docker-compose.yml docker-compose.yml
fi
cp docker/dev-docker-database.yml config/database.yml
cp docker/dev-docker-aquarium.notrb config/initializers/aquarium.rb

# not deleting the original development.rb environment
mv config/environments/development.rb config/environments/original-development.notrb
cp docker/dev-docker-development.rb config/environments/development.rb