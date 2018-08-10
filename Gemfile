source 'https://rubygems.org'

# Rails version
gem 'rails', '4.2.10'

# SQL adapter
gem 'mysql2', '~> 0.3.17'

# Needed for rails 3.2 => 4.0 upgrade
gem 'protected_attributes'

# Json helpers
gem 'rails-patch-json-encode'
gem 'oj'

# Authentication and cross origin
gem 'angular_rails_csrf', '2.1.1'
gem 'rack-cors', require: 'rack/cors'

# Style enforcer and linter
gem 'rubocop'

# For documentation
gem 'yard'
gem 'yard-activerecord'

# Various style related gems
gem 'will_paginate'
gem 'sass-rails'
gem 'github-markup'
gem 'redcarpet'

# For uploads and cloud storage
gem 'paperclip'
gem 'aws-sdk', '~> 1.7.1'

# For bulk inserts (e.g. for loading a collection from a matrix)
gem 'activerecord-import'

group :test do
  gem 'sqlite3'
end

group :development do
  gem 'fakes3'
  gem 'rspec-rails'
  gem 'web-console', '~> 2.0'  
end

group :production do
  gem 'puma'
end

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'closure-compiler'
  gem 'bcrypt-ruby', '~> 3.1.2'
end
