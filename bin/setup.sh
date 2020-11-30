#!/bin/bash
set -uxo pipefail

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
    local variable='TZ'
    _has_variable $variable $env_file
    if [[ $? -gt 0 ]]; then
        local timezone=`curl https://ipapi.co/timezone` 2> /dev/null
        _set_variable $variable $timezone $env_file
    fi
}

mkdir -p $ENV_DIR/development
sub_dir=$ENV_DIR/development
env_file=$sub_dir/backend
touch $env_file
_set_variable 'DB_HOST' 'db' $env_file
_set_variable 'DB_PORT' '3306' $env_file
_set_variable 'SESSION_TIMEOUT' '15' $env_file


env_file=$ENV_DIR/development/db
touch $env_file
db_name='aquarium_development'
_set_variable 'DB_NAME' $db_name $env_file
_set_variable 'MYSQL_DATABASE' $db_name $env_file
db_user='aquarium'
_set_variable 'DB_USER' $db_user $env_file
_set_variable 'MYSQL_USER' $db_user $env_file
db_password='aSecretAquarium'
_set_variable 'DB_PASSWORD' $db_password $env_file
_set_variable 'MYSQL_PASSWORD' $db_password $env_file
_set_variable 'MYSQL_ROOT_PASSWORD' $db_password $env_file

env_file=$sub_dir/timezone
touch $env_file
_set_timezone $env_file

# TODO: allow user to set other values
# TODO: make this a git post-checkout hook, though don't replace secret_key_base
