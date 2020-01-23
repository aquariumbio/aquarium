#!/bin/bash
new_key_base=`openssl rand -hex 64`
s3_key=`openssl rand -hex 40`
ENV_FILE=.env

if [[ -f "$ENV_FILE" ]]; then
    if grep -Fq "SECRET_KEY_BASE=" $ENV_FILE; then
        sed -i '' "s/^SECRET_KEY_BASE=.*/SECRET_KEY_BASE=$new_key_base/g"  $ENV_FILE
    else
        echo 'SECRET_KEY_BASE='$new_key_base >> $ENV_FILE
    fi
else
    echo 'DB_NAME=production' >> $ENV_FILE 
    echo 'DB_USER=aquarium' >> $ENV_FILE
    echo 'DB_PASSWORD=aSecretAquarium' >> $ENV_FILE
    echo 'S3_SERVICE=minio' >> $ENV_FILE
    echo 'S3_ID=aquarium_minio' >> $ENV_FILE
    echo 'S3_SECRET_ACCESS_KEY='$s3_key >> $ENV_FILE
    echo 'TIMEZONE=America/Los_Angeles' >> $ENV_FILE
    echo 'SECRET_KEY_BASE='$new_key_base >> $ENV_FILE 
fi


# TODO: allow user to set other values
# TODO: make this a git post-checkout hook, though don't replace secret_key_base
