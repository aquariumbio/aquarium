ARG RUBY_VERSION=2.6.5
ARG ALPINE_VERSION=3.10

# A ruby-alpine image for development
FROM ruby:${RUBY_VERSION}-alpine${ALPINE_VERSION} AS aquarium-development
RUN apk add --update --no-cache \
    bind-tools \
    build-base \
    file \
    git \
    imagemagick \
    iptables \
    libgcrypt-dev \
    libxml2 \
    libxslt \
    mariadb-dev \
    musl \
    mysql-client \
    nodejs \
    nodejs-npm \
    openjdk8-jre \
    openssl \
    sqlite-dev \
    tzdata \
    yarn

RUN mkdir /aquarium
WORKDIR /aquarium

# install js components
COPY package.json ./package.json
COPY yarn.lock ./yarn.lock

RUN yarn install --modules-folder public/node_modules \
 && yarn cache clean

# Change where bundler puts gems
# see https://bundler.io/v2.0/guides/bundler_docker_guide.html
ENV GEM_HOME="/usr/local/bundle"
ENV PATH $GEM_HOME/bin:$GEM_HOME/gems/bin:$PATH

# Install gems needed by Aquarium
COPY Gemfile Gemfile.lock ./
RUN gem update --system \
 #
 # rails 4.2.11.1 requires bundler < 2.0
 && gem install bundler --version '< 2.0' \
 && bundle install --jobs 20 --retry 5

COPY . ./

# include entrypoint scripts for starting Aquarium and Krill
RUN chmod +x ./entrypoint.sh


# Temporary stage for building production environment based on development stage
FROM aquarium-development AS aquarium-builder

# directories used by puma configuration in production
RUN mkdir -p /aquarium/shared/sockets \
 && mkdir -p /aquarium/shared/log \
 && mkdir -p /aquarium/shared/pids \
 #
 # Precompile assets
 # This requires an active database connection, use nulldb:
 # http://blog.zeit.io/use-a-fake-db-adapter-to-play-nice-with-rails-assets-precompilation/
 && RAILS_ENV=production SECRET_KEY_BASE=foo DB_ADAPTER=nulldb bundle exec rake assets:precompile --trace \
 #
 # Clean up from build
 && rm -rf /usr/local/bundle/cache/*.gem \
 && find /usr/local/bundle/gems/ -name "*.c" -delete \
 && find /usr/local/bundle/gems/ -name "*.o" -delete 
# && rm -rf public/node_modules tmp/cache lib/assets spec test


# A ruby-alpine image for production stage
FROM ruby:${RUBY_VERSION}-alpine${ALPINE_VERSION} AS aquarium

RUN apk add --update --no-cache \
    bind-tools \
    file \
    imagemagick \
    iptables \
    mariadb-dev \
    mysql-client \
    tzdata \
 && mkdir /aquarium

WORKDIR /aquarium

# pull gems from builder stage
COPY --from=aquarium-builder /usr/local/bundle/ /usr/local/bundle/
ENV GEM_HOME="/usr/local/bundle"
ENV PATH $GEM_HOME/bin:$GEM_HOME/gems/bin:$PATH

# pull app from builder-stage
COPY --from=aquarium-builder /aquarium /aquarium
