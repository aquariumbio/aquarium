ARG RUBY_VERSION=2.5
FROM ruby:${RUBY_VERSION}-alpine AS builder
RUN apk update && apk add \
    build-base \
    file \
    imagemagick \
    mariadb-dev \
    mysql-client \
    nodejs \
    nodejs-npm \
    sqlite-dev \
    git 

RUN mkdir /aquarium
WORKDIR /aquarium

RUN gem install bundler
COPY Gemfile /aquarium/Gemfile
RUN bundle install

RUN npm install -g bower@latest
COPY bower.json /aquarium/bower.json
RUN echo '{ "directory": "public/components", "allow_root": true }' > /aquarium/.bowerrc
RUN bower install --config.interactive=false --force

COPY ./docker/aquarium-entrypoint.sh /aquarium/aquarium-entrypoint.sh
RUN chmod +x /aquarium/aquarium-entrypoint.sh
COPY . /aquarium
