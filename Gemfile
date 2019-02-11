source 'https://rubygems.org'

# Rails version
gem 'rails', '4.2.10'

# SQL adapter
gem 'mysql2', '~> 0.4.10'

# Needed for rails 3.2 => 4.0 upgrade
gem 'protected_attributes'
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
gem 'yard'
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

group :test do
  gem 'sqlite3'
  gem 'factory_bot_rails'
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

gem 'PriorityQueue'

# Klavins lab gems
gem 'anemone', :git => 'https://github.com/klavinslab/anemone'
gem 'aquadoc', :git => 'https://github.com/klavinslab/aquadoc'



