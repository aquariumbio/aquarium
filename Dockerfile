ARG RUBY_VERSION=2.6
ARG ALPINE_VERSION=3.8
FROM ruby:${RUBY_VERSION}-alpine${ALPINE_VERSION} AS aquarium
RUN apk update && apk add \
    bind-tools \
    build-base \
    file \
    git \
    imagemagick \
    iptables \
    libxml2 \
    libxslt \
    mariadb-dev \
    mysql-client \
    nodejs \
    nodejs-npm \
    openjdk8-jre \
    sqlite-dev \
    yarn

RUN mkdir /aquarium

# directories used by puma configuration in production
RUN mkdir -p /aquarium/shared/sockets
RUN mkdir -p /aquarium/shared/log
RUN mkdir -p /aquarium/shared/pids

WORKDIR /aquarium

# install js components
COPY package.json ./package.json
COPY yarn.lock ./yarn.lock
RUN yarn install --modules-folder public/node_modules && yarn cache clean

# Change where bundler puts gems
# see https://bundler.io/v2.0/guides/bundler_docker_guide.html
ENV GEM_HOME="/usr/local/bundle"
ENV PATH $GEM_HOME/bin:$GEM_HOME/gems/bin:$PATH

# Install gems needed by Aquarium
COPY Gemfile Gemfile.lock ./
RUN gem update --system
# rails 4.2.11.1 requires bundler < 2.0
RUN gem install bundler --version '< 2.0' && \
    bundle install --jobs 20 --retry 5
COPY . ./

# include entrypoint scripts for starting Aquarium and Krill
RUN chmod +x ./docker/aquarium-entrypoint.sh
RUN chmod +x ./docker/krill-entrypoint.sh
