# frozen_string_literal: true

source 'https://rubygems.org'

# Rails version
gem 'rails', '4.2.11.1'

# SQL adapter
gem 'mysql2', '~> 0.5.2'

# Needed for rails 3.2 => 4.0 upgrade
gem 'protected_attributes_continued'
gem 'tzinfo-data'

# Json helpers
gem 'oj'
gem 'rails-patch-json-encode'

# Authentication and cross origin
gem 'angular_rails_csrf', '2.1.1'
gem 'rack-cors', require: 'rack/cors'

# Style enforcer and linter
gem 'rubocop'

# For documentation
gem 'yard', '>= 0.9.20'
gem 'yard-activerecord'

# Various style related gems
gem 'github-markup'
gem 'redcarpet'
gem 'sassc-rails'
gem 'will_paginate'

# For uploads and cloud storage
gem 'aws-sdk', '~> 1.7.1'
gem 'aws-sdk-s3'
gem 'paperclip'

# For bulk inserts (e.g. for loading a collection from a matrix)
gem 'activerecord-import'

# Factories for testing of aquarium and protocols
gem 'factory_bot_rails'

group :test do
  gem 'sqlite3'
end

group :development do
  gem 'rspec-rails'
  gem 'web-console', '~> 3.0'

  # used to determine subnet for docker containers for web-console
  gem 'ipaddress'
end

group :production do
  gem 'puma'
end

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'bcrypt', '~> 3.1'
  gem 'closure-compiler'
end

# Klavins lab gems
gem 'anemone', git: 'https://github.com/klavinslab/anemone', tag: 'v1.0.1'
gem 'aquadoc', git: 'https://github.com/klavinslab/aquadoc'
