# typed: false
# frozen_string_literal: true

require 'yaml'

#
# Installation specific stuff here
#

s3_host = ENV['S3_HOST'] || 'localhost:9000'
s3_protocol = ENV['S3_PROTOCOL'] || 'http'
default_config = {
  instance_name: 'Your Lab',
  logo_path: 'aquarium-logo.png',
  image_uri: "#{s3_protocol}://#{s3_host}/images/",
  technician_dashboard: false
}
begin
  instance_config = Bioturk::Application.config_for(:instance).symbolize_keys
rescue StandardError => e
  puts("Failed to read instance.yml #{e}")
  instance_config = {}
end
instance_config = default_config.merge(instance_config)
puts(instance_config.to_s)

#
# Name of the instance (Change to the name of your lab)
#
Bioturk::Application.config.instance_name = ENV['INSTANCE_NAME'] || instance_config[:instance_name]

#
# Email address. Required if email service is enabled.
#
Bioturk::Application.config.email_from_address = ENV['LAB_EMAIL_ADDRESS'] || instance_config[:lab_email_address]

#
# Landing page logo (Place file in aquarium/app/assets/images)
#
Bioturk::Application.config.logo_path = ENV['LOGO_PATH'] || instance_config[:logo_path]

#
# URLs
#
Bioturk::Application.config.image_server_interface = ENV['IMAGE_URI'] || instance_config[:image_uri]

#
# Configuration
#
Bioturk::Application.config.krill_port = ENV['KRILL_PORT'] || 3500
Bioturk::Application.config.krill_hostname = ENV['KRILL_HOST'] || 'krill' # for docker NAT

debug_tools = true
debug_tools = ActiveRecord::Type::Boolean.new.type_cast_from_user(ENV['DEBUG_TOOLS']) if ENV['DEBUG_TOOLS']
Bioturk::Application.config.debug_tools = debug_tools # false will hide debug buttons in planner and manager
Bioturk::Application.config.technician_dashboard = ENV['TECH_DASHBOARD']&.casecmp('true')&.zero? || instance_config[:technician_dashboard] # show or hide the technician view dashboard from the top nav menu

# TODO: move this elsewhere
#
# Set CSRF token names
#
Bioturk::Application.config.angular_rails_csrf_options = {
  cookie_name: "XSRF-TOKEN_#{Bioturk::Application.environment_name}",
  header_name: "X-XSRF-TOKEN_#{Bioturk::Application.environment_name}"
}


begin
  # Load the lab user agreement file 'config/user_agreement.yml'.
  # A default file should exist, but it is expected that Docker magic will be
  # used to mount the actual file over top of the default.
  #
  # NOTE: the web says that using using this code to load a YAML dump will fail
  #       because the serialization adds a class type tag to the beginning of
  #       the file.
  user_agreement = YAML.load_file('config/user_agreement.yml').symbolize_keys
  Bioturk::Application.config.user_agreement = UserAgreement.create_from(user_agreement)
rescue StandardError => e
  puts("Failed to read user_agreement.yml #{e}")
  Bioturk::Application.config.user_agreement = nil
end
