

Bioturk::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb
  # config.log_level = :fatal
  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Log error messages when you accidentally call methods on nil.
  config.whiny_nils = true

  # eager loading 
  config.eager_load = false

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Don't care if the mailer can't send
  config.action_mailer.raise_delivery_errors = false

  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :log

  # Only use best-standards-support built into browsers
  config.action_dispatch.best_standards_support = :builtin

  # Raise exception on mass assignment protection for Active Record models
  config.active_record.mass_assignment_sanitizer = :strict

  # Log the query plan for queries taking more than this (works
  # with SQLite, MySQL, and PostgreSQL)
  # Not supported for rails 4
  # config.active_record.auto_explain_threshold_in_seconds = 0.5

  # config.logger = Logger.new(config.paths['log'].first, 1, 1024 * 1024)

  # Assets
  config.assets.compress = false
  #  config.serve_static_assets = false
  config.assets.debug = false

  # config.time_zone = "Pacific Time (US & Canada)"

  # Paperclip => minio
  config.paperclip_defaults = {
    storage: :s3,
    s3_protocol: 'http',
    s3_permissions: 'private',
    s3_region: 'us-west-1', 
    s3_credentials: {
      bucket: 'development',
      access_key_id: 'aquarium_minio',
      secret_access_key: 'KUNAzqrNifmM6GwNVZ8IP7dxZAkYjhnwc0bfdz0W'
    },
    s3_host_name: 's3:9000',
    s3_options: {
      endpoint: "http://s3:9000", # for aws-sdk
      force_path_style: true # for aws-sdk (required for minio)
    }
  }

  # AWS Simple Email Service Config

  # AWS.config(
#    region: ENV.fetch('AWS_REGION'),
#    simple_email_service_endpoint: "email.#{ENV.fetch('AWS_REGION')}.amazonaws.com",
#    simple_email_service_region: ENV.fetch('AWS_REGION'),
#    ses: { region: ENV.fetch('AWS_REGION') },
#    access_key_id: ENV.fetch('AWS_ACCESS_KEY_ID'),
#    secret_access_key: ENV.fetch('AWS_SECRET_ACCESS_KEY')
#  )

end
