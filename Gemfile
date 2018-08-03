source 'https://rubygems.org'

gem 'rails', '4.0.13'

# Needed for rails 4.0.0 upgrade
gem 'protected_attributes'

gem 'will_paginate'
gem 'sass-rails' # TODO 4.0: Make sure sass still compiles somehow. consider switching to sassc gem: https://github.com/sass/sassc-ruby#readme
gem 'mysql2', '~> 0.3.17'
gem 'nokogiri', '~> 1.7.1'
gem 'aws-sdk', '~> 1.7.1'
gem 'test-unit'

group :test do
  gem 'sqlite3'
end

group :development do
  gem 'binding_of_caller'
  gem 'meta_request'
  gem 'fakes3'
  gem 'rspec-rails'
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

gem 'paperclip'

gem 'rails-patch-json-encode'
gem 'oj'

gem 'angular_rails_csrf', '2.1.1'
gem 'rack-cors', require: 'rack/cors'
gem 'redcarpet'
gem 'github-markup'
gem 'rubocop'
gem 'yard'
gem 'yard-activerecord'
