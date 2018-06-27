

Bioturk::Application.configure do
  # Paperclip => fakes3
  config.paperclip_defaults = {
    storage: :s3,
    s3_host_name: 's3.amazonaws.com', # dummy dns-name from fakes3
    bucket: 'AQ_TEST_BUCKET'
  }
end
