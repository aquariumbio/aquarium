# frozen_string_literal: true

#
# Installation specific stuff here
#

default_config = {
  instance_name: 'Your Lab',
  logo_path: 'aquarium-logo.png',
  image_uri: 'http://localhost:9000/images/'
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

Bioturk::Application.config.debug_tools = true # false will hide debug buttons in planner and manager

# TODO: move this elsewhere
#
# Set CSRF token names
#
Bioturk::Application.config.angular_rails_csrf_options = {
  cookie_name: "XSRF-TOKEN_#{Bioturk::Application.environment_name}",
  header_name: "X-XSRF-TOKEN_#{Bioturk::Application.environment_name}"
}


begin
  user_agreement = Bioturk::Application.config_for(:user_agreement).symbolize_keys
  Bioturk::Application.config.user_agreement = UserAgreement.create_from(user_agreement)

rescue StandardError => e
  logger.info("Failed to read user_agreement.yml #{e}")
  Bioturk::Application.config.user_agreement = nil
end
