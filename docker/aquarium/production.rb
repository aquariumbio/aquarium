# frozen_string_literal: true

Bioturk::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  config.eager_load = true

  # Do not reload code -- for production
  config.cache_classes = true

  # Full error reports are disabled and caching is turned on
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true

  # Disable Rails static asset server (Apache or nginx will already do this)
  config.serve_static_files = false

  # Compress JavaScripts and CSS
  config.assets.compress = true
  require 'closure-compiler'
  config.assets.js_compressor = Closure::Compiler.new(
    compilation_level: 'SIMPLE_OPTIMIZATIONS',
    language_in: 'ECMASCRIPT6',
    language_out: 'ES5'
  )

  # Don't fallback to assets pipeline if a pre-compiled asset is missed
  config.assets.compile = false

  # Generate digests for assets URLs
  config.assets.digest = true

  # Specifies the header that your server uses for sending files
  config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect' # for nginx

  # See everything in the log (default is :info)
  config.log_level = :error

  # logging in Docker requires sending logs to STDOUT
  config.logger = ActiveSupport::TaggedLogging.new(Logger.new(STDOUT))

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation can not be found)
  config.i18n.fallbacks = true

  # Send deprecation notices to registered listeners
  config.active_support.deprecation = :notify

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
    s3_host_name: 'localhost:9000',
    s3_options: {
      endpoint: 'http://localhost:9000', # for aws-sdk
      force_path_style: true # for aws-sdk (required for minio)
    }
  }

  # Email notifications in Aquarium assume you ae using the AWS simple email service.
  # To enable, uncomment the following code and set the corresponding environment variables in the docker-compose.override.yml file
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
