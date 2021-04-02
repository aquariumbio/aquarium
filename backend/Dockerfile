ARG RUBY_VERSION=2.7.2
ARG ALPINE_VERSION=3.12

# Build development image
#
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
RUN ["chmod", "+x", "/aquarium/dev_entrypoint.sh"]
ENTRYPOINT [ "/aquarium/dev_entrypoint.sh" ]


# Temporary stage for building production environment based on development
#
FROM backend-development AS backend-builder

# Clean up from build
RUN rm -rf /usr/local/bundle/cache/*.gem \
 && find /usr/local/bundle/gems/ -name "*.c" -delete \
 && find /usr/local/bundle/gems/ -name "*.o" -delete


# Production stage
#
FROM ruby:${RUBY_VERSION}-alpine${ALPINE_VERSION} AS aquarium-backend

RUN apk add --update --no-cache \
    mysql-client \
    netcat-openbsd \
    tzdata \
 && mkdir /aquarium \
 && gem update --system

WORKDIR /aquarium

# pull gems
COPY --from=backend-builder /usr/local/bundle/ /usr/local/bundle/
ENV GEM_HOME="/usr/local/bundle"
ENV PATH $GEM_HOME/bin:$GEM_HOME/gems/bin:$PATH

# pull app
COPY --from=backend-builder /aquarium /aquarium

ENV RAILS_ENV=production
ENV RACK_ENV=production

# Make scripts executable
RUN ["chmod", "+x", "/aquarium/wait-for.sh"] \
 && ["chmod", "+x", "/aquarium/entrypoint.sh"]

ENTRYPOINT [ "/aquarium/entrypoint.sh" ]
CMD ["bin/rails", "s", "-b", "0.0.0.0"]