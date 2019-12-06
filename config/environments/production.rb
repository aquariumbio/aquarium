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

  # See everything in the log (default is :info)
  config.log_level = :error

  # TODO: decide how to deal with logging
  # Writes logs to disk
  config.logger = Logger.new(config.paths['log'].first, 1, 1024 * 1024)
  # logs to STDOUT for standard Docker configuration
  # config.logger = ActiveSupport::TaggedLogging.new(Logger.new(STDOUT))

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation can not be found)
  config.i18n.fallbacks = true

  # Send deprecation notices to registered listeners
  config.active_support.deprecation = :notify

  
  # By default use minio for S3, but set to AWS if S3_SERVICE is set to 'AWS'
  config.paperclip_defaults = if ENV['S3_SERVICE'] && ENV['S3_SERVICE'].casecmp('AWS').zero?
                              {
                                # TODO: change usage of AWS environment variables to instead use S3_
                                storage: :s3,
                                s3_host_name: "s3-#{ENV['AWS_REGION']}.amazonaws.com",
                                s3_permissions: :private,
                                s3_credentials: {
                                  bucket: ENV['S3_BUCKET_NAME'],
                                  access_key_id: ENV['AWS_ACCESS_KEY_ID'],
                                  secret_access_key: ENV['AWS_SECRET_ACCESS_KEY'],
                                  s3_region: ENV['AWS_REGION']
                                }
                              }
                            else
                              s3_host = ENV['S3_HOST'] || 'localhost:9000'
                              {
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
                                  endpoint: "http://#{s3_host}" , # for aws-sdk
                                  force_path_style: true # for aws-sdk (required for minio)
                                }
                              }
                            end
  


  # Email notifications in Aquarium assume you ae using the AWS simple email service.
  # To enable, uncomment the following code and set the corresponding environment variables in the docker-compose.override.yml file
  if ENV['EMAIL_SERVICE']&.casecmp('AWS')&.zero?
    AWS.config(
      region: ENV['AWS_REGION'],
      simple_email_service_endpoint: "email.#{ENV['AWS_REGION']}.amazonaws.com",
      simple_email_service_region: ENV['AWS_REGION'],
      ses: { region: ENV['AWS_REGION'] },
      access_key_id: ENV['AWS_ACCESS_KEY_ID'],
      secret_access_key: ENV['AWS_SECRET_ACCESS_KEY']
    )
  end
end
