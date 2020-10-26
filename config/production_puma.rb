# typed: false
# frozen_string_literal: true

require 'bundler/setup'
require 'erb'

# https://gist.github.com/andrius/7c26a8deef10f3105a136f958b0d582d
workers Integer(ENV['WEB_CONCURRENCY'] || [1, `grep -c processor /proc/cpuinfo`.to_i].max)

# Min and Max threads per worker
threads 1, 6

app_dir = '/aquarium'
shared_dir = "#{app_dir}/shared"

# Default to production
rails_env = ENV['RAILS_ENV'] || 'production'
environment rails_env

# Set up socket location
bind "unix://#{shared_dir}/sockets/puma.sock"

# Logging
stdout_redirect(stdout='/dev/stdout', stderr='/dev/stderr', append=true)

# Set master PID and state locations
pidfile "#{shared_dir}/pids/puma.pid"
state_path "#{shared_dir}/pids/puma.state"
activate_control_app

on_worker_boot do
  require 'active_record'
  begin
    ActiveRecord::Base.connection.disconnect!
  rescue StandardError
    ActiveRecord::ConnectionNotEstablished
  end
  ActiveRecord::Base.establish_connection( YAML.load( ERB.new( File.read( "#{app_dir}/config/database.yml" )).result)[rails_env])
end
