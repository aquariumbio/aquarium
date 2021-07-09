#!/bin/sh
set -euo pipefail

# App is parameterized to allow backend and backend port to be set via
# environment variables. These are instantiated in react build, so to preserve
# ability to parameterize the built environment, use an external file 
# config.json with *only* the variables needed.
#
# This script requires that jo be installed in the Dockerfile

if [ -z ${BUILD_ROOT+x} ]; then
    echo "ERROR: BUILD_ROOT is not set";
    exit 2
fi

# TODO: check this path is correct
rm -f $BUILD_ROOT/helpers/api/config.json
jo REACT_APP_BACKEND=$REACT_APP_BACKEND REACT_APP_BACKEND_PORT=$REACT_APP_BACKEND_PORT > $BUILD_ROOT/helpers/api/config.json

exec "$@"
