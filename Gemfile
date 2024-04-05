# frozen_string_literal: true

source 'https://rubygems.org'

# For bulk inserts (e.g. for loading a collection from a matrix)
gem 'activerecord-import'

# Used to fake db during asset compilation in Dockerfile
gem 'activerecord-nulldb-adapter'

gem 'alphabetical_paginate'

# Authentication and cross origin
gem 'angular_rails_csrf', '5.0.0'

gem 'anemone', path: 'components/anemone'
gem 'aquadoc', path: 'components/aquadoc'

# For uploads and cloud storage
gem 'aws-sdk', '~> 2.0', '>= 2.0.22'
gem 'aws-sdk-s3'

# For email
gem 'aws-sdk-ses'

gem 'bcrypt', '~> 3.1'

gem 'closure-compiler'

# gem 'github-markup'

# SQL adapter
gem 'mysql2', '~> 0.5.2'

# JSON
gem 'oj'

# For uploads
gem 'paperclip', '~> 6.1', '>= 6.1.0'

# Needed for rails 3.2 => 4.0 upgrade
gem 'protected_attributes_continued'

gem 'rack-cors', '~> 1.1.0', require: 'rack/cors'

gem 'rails', '7.0.8.1'
gem 'mimemagic', '>= 0.4.2'

gem 'redcarpet', '>= 3.5.1'

gem 'ruby-units'

gem 'sassc-rails', '>= 2.1.2'

gem 'tzinfo-data'

# allows rails 5 style where().or() queries
gem 'where-or'

gem 'will_paginate'

group :development do
  gem 'factory_bot_rails', '>= 6.0.0'
  gem 'ipaddress' # used to determine subnet for docker containers for web-console
  gem 'rspec-rails', '>= 5.0.0'
  gem 'rspec-sorbet'
  gem 'rubocop'
  gem 'rubocop-rails', '>= 2.12.0'
  gem 'rubocop-sorbet'
  gem 'simplecov', require: false
  gem 'web-console', '~> 3.3', '>= 3.3.1'
  gem 'yard', '>= 0.9.35'
  gem 'yard-activerecord'
end

group :development, :test do
  gem 'sorbet'
end

gem 'sorbet-rails', '0.5.6'
gem 'sorbet-runtime'

group :production do
  gem 'puma'
end
