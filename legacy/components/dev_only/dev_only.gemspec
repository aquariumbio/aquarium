$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "dev_only/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "dev_only"
  s.version     = DevOnly::VERSION
  s.authors     = [""]
  s.email       = [""]
  s.homepage    = ""
  s.summary     = "Summary of DevOnly."
  s.description = "Description of DevOnly."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 4.2.11.3"

  s.add_development_dependency "sqlite3"
end
