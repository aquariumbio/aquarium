ARG RUBY_VERSION=2.5
FROM ruby:${RUBY_VERSION}-alpine AS basebuilder
RUN apk update && apk add \
    bind-tools \
    build-base \
    file \
    git \
    imagemagick \
    iptables \
    mariadb-dev \
    mysql-client \
    nodejs \
    nodejs-npm \
    openjdk8-jre \
    yarn \
    sqlite-dev

RUN mkdir /aquarium

# directories used by puma configuration in production
RUN mkdir -p /aquarium/shared/sockets
RUN mkdir -p /aquarium/shared/log
RUN mkdir -p /aquarium/shared/pids

WORKDIR /aquarium

# install js components
COPY package.json ./package.json
COPY yarn.lock ./yarn.lock
RUN yarn install && yarn cache clean

# install gems needed by Aquarium
COPY Gemfile Gemfile.lock ./
RUN gem update --system
RUN gem install bundler && bundle install --jobs 20 --retry 5
COPY . ./

# include entrypoint scripts for starting Aquarium and Krill
RUN chmod +x ./docker/aquarium-entrypoint.sh
RUN chmod +x ./docker/krill-entrypoint.sh
