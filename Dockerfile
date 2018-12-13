ARG RUBY_VERSION=2.5
FROM ruby:${RUBY_VERSION}-alpine AS basebuilder
RUN apk update && apk add \
    build-base \
    file \
    imagemagick \
    mariadb-dev \
    mysql-client \
    nodejs \
    nodejs-npm \
    openjdk8-jre \
    sqlite-dev \
    git 

RUN mkdir /aquarium
RUN mkdir -p /aquarium/shared
WORKDIR /aquarium

RUN npm install -g bower@latest
COPY bower.json ./bower.json
RUN echo '{ "directory": "public/components", "allow_root": true }' > ./.bowerrc
RUN bower install --config.interactive=false --force

COPY Gemfile Gemfile.lock ./
RUN gem install bundler && bundle install --jobs 20 --retry 5
COPY . ./

RUN chmod +x ./docker/aquarium-entrypoint.sh
RUN chmod +x ./docker/krill-entrypoint.sh
