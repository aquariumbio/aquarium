Gem::Specification.new do |s|
  s.name        = 'aquadoc'
  s.version     = '0.0.0'
  s.date        = '2018-11-02'
  s.summary     = "A Documentation Generator for Aquarium Workflows"
  s.description = "Use this tool to publish your workflows!"
  s.authors     = ["Eric Klavins"]
  s.email       = 'klavins@uw.edu'
  s.files       = [
    "lib/aquadoc.rb",
    "lib/aquadoc/make.rb",
    "lib/aquadoc/render.rb",
    "lib/assets/index_part_1.html",
    "lib/assets/index_part_2.html",
    "lib/assets/aquadoc.css",
    "lib/assets/aquadoc.js",
    "lib/assets/yard_templates/default/onefile/html/layout.erb",
    "lib/assets/yard_templates/default/onefile/html/setup.rb"
  ]
  s.add_runtime_dependency "yard", ">= 0.9.11"
  s.homepage    = 'http://klavinslab.org/protocols'
  s.license     = 'MIT'
  s.bindir      = 'bin'
  s.executables << 'aquadoc'
  s.post_install_message = "Thanks for installing Aquadoc!"
end
