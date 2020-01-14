#!/bin/bash
echo 'SECRET_KEY_BASE='`openssl rand -hex 64` > .env 

# TODO: have script add line if not defined, so that doesn't overwrite
