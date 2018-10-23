ARG RUBY_VERSION=2.3.7
FROM ruby:${RUBY_VERSION}-alpine AS base
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

# copy everything in directory to image. probably want to be more selective.
COPY . /aquarium

# copy rails configuration files for dockerized aquarium
COPY ./docker/aquarium/database.yml /aquarium/config/database.yml
COPY ./docker/aquarium/aquarium.rb /aquarium/config/initializers/aquarium.rb
COPY ./docker/aquarium/development.rb /aquarium/config/environments/development.rb
COPY ./docker/aquarium/production.rb /aquarium/config/environments/production.rb

# copy endpoints for aquarium and krill
COPY ./docker/aquarium-entrypoint.sh /aquarium/aquarium-entrypoint.sh
RUN chmod +x /aquarium/aquarium-entrypoint.sh
COPY ./docker/krill-entrypoint.sh /aquarium/krill-entrypoint.sh
RUN chmod +x /aquarium/krill-entrypoint.sh

# make sure the host has directories that the compose file is expecting
RUN mkdir -p ./docker/db
RUN mkdir -p ./docker/s3/data/development
RUN mkdir -p ./docker/s3/config









