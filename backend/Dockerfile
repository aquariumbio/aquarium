ARG RUBY_VERSION=2.7.2
ARG ALPINE_VERSION=3.12

# A ruby-alpine image for development
FROM ruby:${RUBY_VERSION}-alpine${ALPINE_VERSION} AS backend-development

# throw errors if Gemfile has been modified since Gemfile.lock
#RUN bundle config --global frozen 1

RUN apk add --update --no-cache \
    build-base \
    mariadb-dev \
    mysql-client \
    tzdata

RUN mkdir -p /aquarium
WORKDIR /aquarium

# Change where bundler puts gems
# see https://bundler.io/v2.0/guides/bundler_docker_guide.html
ENV GEM_HOME="/usr/local/bundle"
ENV PATH $GEM_HOME/bin:$GEM_HOME/gems/bin:$PATH

# Install gems needed by Aquarium
COPY Gemfile Gemfile.lock ./

# Woraround for Rails dependency on mimemagic 0.3.5
RUN mkdir -p /aquarium/local
COPY local/mimemagic-0.3.5.gem ./local/mimemagic-0.3.5.gem

RUN gem update --system \
  && gem install bundler \
  && bundle install --jobs 20 --retry 5

COPY . ./

# include entrypoint scripts for starting Aquarium and Krill
RUN chmod +x dev_entrypoint.sh
ENTRYPOINT [ "/aquarium/dev_entrypoint.sh" ]
