#!/bin/bash
ENV_FILE=.env

_has_variable() {
    variable=$1
    grep -q "^$variable" $ENV_FILE
    if [[ $? -eq 0 ]]; then
        return 0
    else
        return 1
    fi
}

_set_value() {
    variable=$1
    value=$2
    echo $variable=$value >> $ENV_FILE
}

_set_variable() {
    variable=$1
    value=$2
    _has_variable $variable
    if [[ $? -gt 0 ]]; then
       _set_value $variable $value
    fi
}

_set_random() {
    variable=$1
    length=$2
    _has_variable $variable
    if [[ $? -gt 0 ]]; then
        value=`openssl rand -hex $length`
        _set_value $variable $value
    fi
}

_set_timezone() {
    _has_variable 'TIMEZONE'
    if [[ $? -gt 0 ]]; then
        timezone=`curl https://ipapi.co/timezone` 2> /dev/null
        _set_variable 'TIMEZONE' $timezone
    fi
}

if [[ ! -f "$ENV_FILE" ]]; then
    echo "Initializing configuration file"
    touch $ENV_FILE
fi

_set_variable 'AQUARIUM_VERSION' '2.8.0'
_set_variable 'APP_PUBLIC_PORT' '80'
_set_variable 'S3_PUBLIC_PORT' '9000'
_set_variable 'DB_NAME' 'production'
_set_variable 'DB_USER' 'aquarium'
_set_variable 'DB_PASSWORD' 'aSecretAquarium'
_set_variable 'S3_SERVICE' 'minio'
_set_variable 'S3_ID' 'aquarium_minio'
_set_variable 'S3_REGION' 'us-west-1'
_set_random 'S3_SECRET_ACCESS_KEY' '40'
_set_random 'SECRET_KEY_BASE' '64'
_set_timezone

DB_INIT_DIR=./docker/mysql_init
DB_FILE=$DB_INIT_DIR/dump.sql
if [[ ! -f "$DB_FILE" ]]; then
    cp $DB_INIT_DIR/default.sql $DB_INIT_DIR/dump.sql
fi

# TODO: is it possible to pull the version from elsewhere?
# TODO: allow user to set other values
# TODO: make this a git post-checkout hook, though don't replace secret_key_base