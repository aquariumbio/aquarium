

# Load the rails application
require File.expand_path('application', __dir__)

# Initialize the rails application
begin
  puts 'Calling initialize'
  Bioturk::Application.initialize!
rescue Mysql2::Error => e
  puts "Initialization failed with #{e.class}, message: #{e.message}"
end

# This next line doesn't work in application.rb / after_initialize because the Collection constant name conflicts
# with a rails class of the same name which we've never used (and didn't know about). The best thing to
# do at some point would be to rename this class.
Collection.count
