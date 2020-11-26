#!/bin/bash
ENV_DIR=.env

_has_variable() {
    local variable=$1
    local env_file=$2
    grep -q "^$variable" $env_file
    if [[ $? -eq 0 ]]; then
        return 0
    else
        return 1
    fi
}

_set_value() {
    local variable=$1
    local value=$2
    local env_file=$3
    echo $variable=$value >> $env_file
}

_set_variable() {
    local variable=$1
    local value=$2
    local env_file=$3
    _has_variable $variable $env_file
    if [[ $? -gt 0 ]]; then
       _set_value $variable $value $env_file
    fi
}

_set_random() {
    local variable=$1
    local length=$2
    local env_file=$3
    _has_variable $variable $env_file
    if [[ $? -gt 0 ]]; then
        local value=`openssl rand -hex $length`
        _set_value $variable $value $env_file
    fi
}

_set_timezone() {
    local env_file=$1
    _has_variable 'TIMEZONE' $env_file
    if [[ $? -gt 0 ]]; then
        local timezone=`curl https://ipapi.co/timezone` 2> /dev/null
        _set_variable 'TIMEZONE' $timezone $env_file
    fi
}

mkdir -p $ENV_DIR
env_file=$ENV_DIR/aquarium
_set_variable 'AQUARIUM_VERSION' '2.8.1' $env_file
_set_timezone $env_file
_set_variable 'TECH_DASHBOARD' 'false' $ENV_FILE
_set_variable 'SESSION_TIMEOUT' '15' $ENV_FILE
#_set_random 'SECRET_KEY_BASE' '64' $ENV_FILE

mkdir -p $ENV_DIR/production
env_file=$ENV_DIR/production/web
_set_variable 'APP_PUBLIC_PORT' '80' $env_file

env_file=$ENV_DIR/production/db
_set_variable 'DB_NAME' 'production' $env_file
_set_variable 'DB_USER' 'aquarium' $env_file
_set_variable 'DB_PASSWORD' 'aSecretAquarium' $env_file

DB_INIT_DIR=./docker/mysql_init
DB_FILE=$DB_INIT_DIR/dump.sql
if [[ ! -f "$DB_FILE" ]]; then
    cp $DB_INIT_DIR/default.sql $DB_INIT_DIR/dump.sql
fi

# TODO: is it possible to pull the version from elsewhere?
# TODO: allow user to set other values
# TODO: make this a git post-checkout hook, though don't replace secret_key_base
