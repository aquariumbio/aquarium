#!/bin/bash

# This script places default development config files in the correct places, 
# preparing the environment for a development docker aquarium instance.


# Optionally: start from a fresh database. This will not work when done from the docker toolbox VM.
# For this case, you can instead manually delete the files from the windows file explorer.
# sudo rm -rf docker/db/*       

cp docker/docker-compose.yml .
cp docker/docker-compose.dev.yml .
cp docker/docker-compose.override.yml .

if [[ $1 == "windows" ]]; then
    cp docker/windev-docker-compose.yml docker-compose.yml
fi




