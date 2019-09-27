# frozen_string_literal: true

Bioturk::Application.configure do

  config.eager_load = false

  # Paperclip => fakes3
  config.paperclip_defaults = {
    storage: :s3,
    s3_host_name: 's3.amazonaws.com', # dummy dns-name from fakes3
    bucket: 'AQ_TEST_BUCKET'
  }
end
