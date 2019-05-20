# Be sure to restart your server when you modify this file.

Bioturk::Application.config.session_store :cookie_store, key: "_aquarium_#{Bioturk::Application.environment_name}_session"

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rails generate session_migration")
# Bioturk::Application.config.session_store :active_record_store
