# frozen_string_literal: true

#
# Installation specific stuff here
#
# TODO: allow loading from file to override these settings (maybe don't include environment variables)

#
# Name of the instance (Change to the name of your lab)
#
Bioturk::Application.config.instance_name = ENV['LAB_NAME'] || 'Your Lab'

#
# Landing page logo (Place file in aquarium/app/assets/images)
#
Bioturk::Application.config.logo_path = ENV['LOGO_PATH'] || 'aquarium-logo.png'

#
# URLs
#
Bioturk::Application.config.image_server_interface = ENV['IMAGE_URI'] || 'http://localhost:9000/images/'

#
# Configuration
#
Bioturk::Application.config.debug_tools = true # false will hide debug buttons in planner and manager
Bioturk::Application.config.krill_port = ENV['KRILL_PORT'] || 3500
Bioturk::Application.config.krill_hostname = ENV['KRILL_HOST'] || 'krill' # for docker NAT

# TODO: move this elsewhere
#
# Set CSRF token names
#
Bioturk::Application.config.angular_rails_csrf_options = {
  cookie_name: "XSRF-TOKEN_#{Bioturk::Application.environment_name}",
  header_name: "X-XSRF-TOKEN_#{Bioturk::Application.environment_name}"
}

# Emailer
# Note: You must set up an AWS SimpleEmailService domain for this to work.
#       Also, make sure to set the environment variable AWS_REGION.
#       See config/initializers/production.rb under "email".

Bioturk::Application.config.email_from_address = ENV['LAB_EMAIL_ADDRESS']
