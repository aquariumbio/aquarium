ARG RUBY_VERSION=2.5
ARG ALPINE_VERSION=3.8
FROM ruby:${RUBY_VERSION}-alpine${ALPINE_VERSION} AS basebuilder
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
    sqlite-dev

RUN mkdir /aquarium

# directories used by puma configuration in production
RUN mkdir -p /aquarium/shared/sockets
RUN mkdir -p /aquarium/shared/log
RUN mkdir -p /aquarium/shared/pids

WORKDIR /aquarium

# install js components
RUN npm install -g bower@latest
COPY bower.json ./bower.json
RUN echo '{ "directory": "public/components", "allow_root": true }' > ./.bowerrc
RUN bower install --config.interactive=false --force

# install gems needed by Aquarium
COPY Gemfile Gemfile.lock ./
RUN gem update --system
RUN gem install bundler && bundle install --jobs 20 --retry 5
COPY . ./

# include entrypoint scripts for starting Aquarium and Krill
RUN chmod +x ./docker/aquarium-entrypoint.sh
RUN chmod +x ./docker/krill-entrypoint.sh
