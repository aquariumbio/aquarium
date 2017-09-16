require File.expand_path('../boot', __FILE__)

require 'rails/all'

require './lib/pdl/core/pdl'
require './lib/lang/lang'
require './lib/plankton/plankton'
require './lib/oyster/oyster'
require './lib/repo/repo'
require './lib/manta/manta'
require './lib/krill/krill'

if defined?(Bundler)
  # If you precompile assets before deploying to production, use this line
  Bundler.require(*Rails.groups(:assets => %w(development test)))
  # If you want your assets lazily compiled in production, use this line
  # Bundler.require(:default, :assets, Rails.env)
end

# This variable holds the current job id, or is negative if there is no current job
$CURRENT_JOB_ID = -1

module Bioturk

  class Application < Rails::Application

    # Paperclip
    if Rails.env != 'production'
      config.paperclip_defaults = { :url=>"/system/#{Rails.env}/:class/:attachment/:id_partition/:style/:filename" }
    end

    # config.threadsafe!

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Custom directories with classes and modules you want to be autoloadable.
    # config.autoload_paths += %W(#{config.root}/lib/plankton/**/)

    # Only load the plugins named here, in the order given (default is alphabetical).
    # :all can be used as a placeholder for all plugins not explicitly named.
    # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

    # Activate observers that should always be running.
    # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    config.time_zone = 'Pacific Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password]

    # Enable escaping HTML in JSON.
    config.active_support.escape_html_entities_in_json = true

    # Use SQL instead of Active Record's schema dumper when creating the database.
    # This is necessary if your schema can't be completely dumped by the schema dumper,
    # like if you have constraints or database-specific column types
    # config.active_record.schema_format = :sql

    # Enforce whitelist mode for mass assignment.
    # This will create an empty whitelist of attributes available for mass-assignment for all models
    # in your app. As such, your models will need to explicitly whitelist or blacklist accessible
    # parameters by using an attr_accessible or attr_protected declaration.
    config.active_record.whitelist_attributes = true

    # Enable the asset pipeline
    config.assets.enabled = true

    # Version of your assets, change this if you want to expire all your assets
    config.assets.version = '1.0'

    # The following code touches all the models, which somehow initializes the constants
    # representing those models. If you don't do this, you get "wrong constant" errors in
    # plugins and possibly other places.
    config.after_initialize do
        Job.count if Job.table_exists?
        Sample.count if Sample.table_exists?
        Item.count if Item.table_exists?
        User.count if User.table_exists?
        Metacol.count if Metacol.table_exists?
        Group.count if Group.table_exists?
        Locator.count if Locator.table_exists?
        Wizard.count if Wizard.table_exists?
        SampleType.count if SampleType.table_exists?
        ObjectType.count if ObjectType.table_exists?
        TaskPrototype.count if TaskPrototype.table_exists?
        Task.count if Task.table_exists?
        Parameter.count if Parameter.table_exists?
        DataAssociation.count if DataAssociation.table_exists?
        Upload.count if Upload.table_exists?
        OperationType.count if OperationType.table_exists?
        FieldType.count if FieldType.table_exists?
        FieldValue.count if FieldValue.table_exists?
        AllowableFieldType.count if AllowableFieldType.table_exists?
        Operation.count if Operation.table_exists?
        VirtualOperation.count if VirtualOperation.table_exists?
        Plan.count if Plan.table_exists?
        Wire.count if Wire.table_exists?
        PlanAssociation.count if PlanAssociation.table_exists?
        JobAssociation.count if JobAssociation.table_exists?
        Library.count if Library.table_exists?
    end

    #Added to enable CORS
    config.middleware.insert_before 0, "Rack::Cors" do
      allow do
        origins '*'
        resource '*', :headers => :any, :methods => [:get, :post, :options]
      end
    end

    # Creates the environment name for the Aquarium instance by concatenating with the instance name with the
    # environment type.
    # The name is a US-ASCII string consisting only of alphanumeric characters.
    #
    # @return [String] the environment name for the Aquarium instance
    def self.environment_name
      instance_name =config.instance_name
          .encode(Encoding::US_ASCII, :undef => :replace, :invalid => :replace, :replace => "")
          .gsub(/[^[:alnum:]]/,'')
      "#{instance_name}_#{Rails.env}"
    end


  end

end
