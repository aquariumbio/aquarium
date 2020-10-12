# typed: false
# frozen_string_literal: true

require 'resolv'
require 'ipaddress'

Bioturk::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  config.eager_load = false

  # Reload code on request -- for development
  config.cache_classes = false

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Log error messages when you accidentally call methods on nil.
  config.whiny_nils = true

  # Don't care if the mailer can't send
  config.action_mailer.raise_delivery_errors = false

  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :log

  # Only use best-standards-support built into browsers
  config.action_dispatch.best_standards_support = :builtin

  # Raise exception on mass assignment protection for Active Record models
  config.active_record.mass_assignment_sanitizer = :strict

  # logging in Docker requires sending logs to STDOUT
  config.logger = ActiveSupport::TaggedLogging.new(Logger.new(STDOUT))

  # Assets
  config.assets.compress = false
  #  config.serve_static_assets = false
  config.assets.debug = false
  # use dev directory for assets
  config.assets.prefix = "/dev-assets"

  # config.time_zone = "Pacific Time (US & Canada)"

  # Paperclip => minio
  s3_host = ENV['S3_HOST'] || 'localhost:9000'
  config.paperclip_defaults = {
    storage: :s3,
    s3_protocol: 'http',
    s3_permissions: 'private',
    s3_region: ENV['S3_REGION'] || 'us-west-1',
    s3_credentials: {
      bucket: ENV['S3_BUCKET_NAME'] || 'development',
      access_key_id: ENV['S3_ACCESS_KEY_ID'],
      secret_access_key: ENV['S3_SECRET_ACCESS_KEY']
    },
    s3_host_name: s3_host,
    s3_options: {
      endpoint: "http://#{s3_host}", # for aws-sdk
      force_path_style: true # for aws-sdk (required for minio)
    }
  }

  # when running in docker, web_console complains about rendering from container
  # addresses.  May be sufficient to turn off the whining, but to be sure nothing
  # is missed, this code whitelists the IP addresses of the services so that
  # they are able to render to the console if needed.
  # To do this, the following resolves service hostnames to IP addresses and
  # then creates an array of address summaries that is used for whitelisting.
  # It then turns off whining about IP addresses.
  ip_list = []
  service_names = %w[db s3 krill app]
  service_names.each do |name|
    ip = Resolv.getaddress(name)
    ip_list.push(IPAddress(ip))
  rescue Resolv::ResolvError
    puts "service #{name} not resolved"

  end

  service_ips = IPAddress::IPv4.summarize(*ip_list).map(&:to_string)

  # whitelist summarized IP addresses for services
  config.web_console.whitelisted_ips = service_ips
  # don't whine about other addresses
  config.web_console.whiny_requests = false

  # Email notifications in Aquarium assume you ae using the AWS simple email service.
  # To enable, uncomment the following code and set the corresponding environment variables in the docker-compose.override.yml file
  # There is no substitute for AWS simple email service in development.
  #
  # AWS.config(
  #   region: ENV.fetch('AWS_REGION'),
  #   simple_email_service_endpoint: "email.#{ENV.fetch('AWS_REGION')}.amazonaws.com",
  #   simple_email_service_region: ENV.fetch('AWS_REGION'),
  #   ses: { region: ENV.fetch('AWS_REGION') },
  #   access_key_id: ENV.fetch('AWS_ACCESS_KEY_ID'),
  #   secret_access_key: ENV.fetch('AWS_SECRET_ACCESS_KEY')
  # )

end
