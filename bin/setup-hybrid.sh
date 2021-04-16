#!/bin/bash
set -uxo pipefail

ENV_DIR='.env_files'

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

_get_timezone() {
    if [[ -z ${timezone+x} ]]; then
        timezone=`curl https://ipapi.co/timezone` 2> /dev/null
    fi

    if [[ ${timezone} =~ 'error' ]]; then
        echo 'Error getting timezone'
        timezone='America/Los_Angeles'
        echo 'Using ${timezone}'
    fi
}

_set_timezone() {
    local env_file=$1
    local variable='TZ'
    _has_variable $variable $env_file
    if [[ $? -gt 0 ]]; then
        _get_timezone
        _set_variable $variable $timezone $env_file
    fi
}

_create_compose_config() {
    local env_file=$1
    touch $env_file
    _set_variable 'LEGACY_VERSION' '2.9.0' $env_file
    _set_variable 'LEGACY_PUBLIC_PORT' '3100' $env_file   
    _set_variable 'S3_SERVICE' 'minio' $env_file
    _set_variable 'S3_ID' 'aquarium_minio' $env_file
    _set_variable 'S3_REGION' 'us-west-1' $env_file
    _set_random 'S3_SECRET_ACCESS_KEY' '40'  $env_file
}

_create_config() {
    local environment=$1
    local sub_dir=$ENV_DIR/$environment

    mkdir -p $sub_dir

    local db_name="aquarium_$environment"
    local db_user=$2
    local db_password=$3

    local env_file=$sub_dir/legacy
    touch $env_file

    _set_variable 'DB_HOST' 'db' $env_file
    _set_variable 'DB_PORT' '3306' $env_file
    _set_variable 'DB_NAME' $db_name $env_file
    _set_variable 'DB_PASSWORD' $db_password $env_file
    _set_variable 'DB_USER' $db_user $env_file
    _set_random 'SECRET_KEY_BASE' '64' $env_file
    _set_variable 'TECH_DASHBOARD' 'false' $env_file
}

# Need a .env file to parameterize the compose file
_create_compose_config '.env'

# Otherwise, set environment variables in $ENV_DIR
_create_config 'development' 'aquarium' 'aSecretAquarium'
_create_config 'production' 'aquarium' 'aSecretAquarium'

# TODO: allow user to set other values
# TODO: make this a git post-checkout hook, though don't replace secret_key_base
