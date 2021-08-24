#!/bin/sh
set -euo pipefail

# App is parameterized to allow backend and backend port to be set via
# environment variables. These are instantiated in react build, so to preserve
# ability to parameterize the built environment, use an external file 
# config.json with *only* the variables needed.

if [ -z ${BUILD_ROOT+x} ]; then
    echo "ERROR: BUILD_ROOT is not set";
    exit 2
fi

if [ -z ${REACT_APP_BACKEND+x} ]; then
    echo "ERROR: REACT_APP_BACKEND is not set";
    exit 2
fi

if [ -z ${REACT_APP_BACKEND_PORT+x} ]; then
    echo "ERROR: REACT_APP_BACKEND_PORT is not set";
    exit 2
fi

for file in $BUILD_ROOT/static/js/*.js;
do
    (cat $file | envsubst '$REACT_APP_BACKEND,$REACT_APP_BACKEND_PORT' > $file.temp; mv $file.temp $file);
done

exec "$@"
