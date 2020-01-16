#!/bin/bash
new_key=`openssl rand -hex 64`
ENV_FILE=.env

if [[ -f "$ENV_FILE" ]]; then
    if grep -Fq "SECRET_KEY_BASE=" $ENV_FILE; then
        sed -i '' "s/^SECRET_KEY_BASE=.*/SECRET_KEY_BASE=$new_key/g"  $ENV_FILE
    else
        echo 'SECRET_KEY_BASE='$new_key >> $ENV_FILE
    fi
else
    echo 'DB_NAME=production' >> $ENV_FILE 
    echo 'DB_USER=aquarium' >> $ENV_FILE
    echo 'DB_PASSWORD=aSecretAquarium' >> $ENV_FILE
    echo 'S3_ID=aquarium_minio' >> $ENV_FILE
    echo 'S3_SECRET_ACCESS_KEY=KUNAzqrNifmM6GwNVZ8IP7dxZAkYjhnwc0bfdz0W' >> $ENV_FILE
    echo 'TIMEZONE=America/Los_Angeles' >> $ENV_FILE
    echo 'SECRET_KEY_BASE='$new_key >> $ENV_FILE 
fi


# TODO: allow user to set other values
# TODO: make this a git post-checkout hook, though don't replace secret_key_base
