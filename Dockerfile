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
WORKDIR /aquarium

RUN npm install -g bower@latest
COPY bower.json /aquarium/bower.json
RUN echo '{ "directory": "public/components", "allow_root": true }' > /aquarium/.bowerrc
RUN bower install --config.interactive=false --force

COPY . /aquarium

# copy configuration files to run Aquarium within Docker and
# using the s3 and db services. 
COPY ./docker/aquarium-entrypoint.sh /aquarium/aquarium-entrypoint.sh
RUN chmod +x /aquarium/aquarium-entrypoint.sh
COPY ./docker/krill-entrypoint.sh /aquarium/krill-entrypoint.sh
RUN chmod +x /aquarium/krill-entrypoint.sh

COPY ./docker/aquarium/database.yml /aquarium/config/database.yml
COPY ./docker/aquarium/aquarium.rb /aquarium/config/initializers/aquarium.rb
COPY ./docker/aquarium/development.rb /aquarium/config/environments/development.rb
COPY ./docker/aquarium/production.rb /aquarium/config/environments/production.rb

RUN mkdir -p ./docker/db
RUN mkdir -p ./docker/s3/data/development
RUN mkdir -p ./docker/s3/config

FROM basebuilder AS devbuilder
ENV RAILS_ENV development 
ENV RACK_ENV development
WORKDIR /aquarium
RUN gem install bundler
COPY ./Gemfile /aquarium/Gemfile
RUN bundle install

FROM basebuilder AS prodbuilder
ENV RAILS_ENV production 
ENV RACK_ENV production
WORKDIR /aquarium
RUN gem install bundler
COPY ./Gemfile /aquarium/Gemfile
RUN bundle install
COPY ./docker/aquarium/production_puma.rb /aquarium/config/production_puma.rb
RUN mkdir /aquarium/shared
