begin
  Bioturk::Application.config.aquarium_version = `git rev-list HEAD --count`.strip
rescue
  Bioturk::Application.config.aquarium_version = "unknown"
end

puts "Aquarium Version #{Bioturk::Application.config.aquarium_version} Starting!"
