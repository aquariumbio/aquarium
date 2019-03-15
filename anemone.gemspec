$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "anemone/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "anemone"
  s.version     = Anemone::VERSION
  s.authors     = ["Eric Klavins"]
  s.email       = ["klavins@uw.edu"]
  s.homepage    = "http://klavinslab.org"
  s.summary     = "Allows you to run background workers and query their statuses later."
  s.description = "Allows you to run background workers and query their statuses later."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  s.add_dependency "rails", '4.2.11.1'

  s.add_development_dependency "sqlite3"
end
