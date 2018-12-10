require 'resolv'
require 'ipaddress'

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

  # Limit the size of log files
  config.logger = Logger.new(config.paths['log'].first, 1, 1024 * 1024)

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation can not be found)
  config.i18n.fallbacks = true

  # Send deprecation notices to registered listeners
  config.active_support.deprecation = :notify

  # Paperclip => S3

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

  # when running in docker, web_console complains about rendering from container
  # addresses.  May be sufficient to turn off the whining, but to be sure nothing
  # is missed, this code whitelists the IP addresses of the services so that
  # they are able to render to the console if needed.
  # To do this, the following resolves service hostnames to IP addresses and
  # then creates an array of address summaries that is used for whitelisting.
  # It then turns off whining about IP addresses.
  ip_list = []
  service_names = ['db', 's3', 'krill', 'app']
  service_names.each do |name|
    begin
      ip = Resolv.getaddress(name)
      ip_list.push(IPAddress(ip))
    rescue Resolv::ResolvError
      puts "service #{name} not resolved"
    end
  end

  service_ips = IPAddress::IPv4.summarize(*ip_list).map(&:to_string)

  # whitelist summarized IP addresses for services
  config.web_console.whitelisted_ips = service_ips
  # don't whine about other addresses
  config.web_console.whiny_requests = false

  # AWS Simple Email Service Config
  #AWS.config(
  #  region: ENV.fetch('AWS_REGION'),
  #  simple_email_service_endpoint: "email.#{ENV.fetch('AWS_REGION')}.amazonaws.com",
  #  simple_email_service_region: ENV.fetch('AWS_REGION'),
  #  ses: { region: ENV.fetch('AWS_REGION') },
  #  access_key_id: ENV.fetch('AWS_ACCESS_KEY_ID'),
  #  secret_access_key: ENV.fetch('AWS_SECRET_ACCESS_KEY')
  #)

end
