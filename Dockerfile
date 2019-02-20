ARG RUBY_VERSION=2.5
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
RUN yarn install && yarn cache clean

# install gems needed by Aquarium
COPY Gemfile Gemfile.lock ./
RUN gem update --system
RUN gem install bundler && \
    bundle config build.nokogiri --use-system-libraries \
    bundle install --jobs 20 --retry 5
COPY . ./

# include entrypoint scripts for starting Aquarium and Krill
RUN chmod +x ./docker/aquarium-entrypoint.sh
RUN chmod +x ./docker/krill-entrypoint.sh
