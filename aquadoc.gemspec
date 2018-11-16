Gem::Specification.new do |s|
  s.name        = 'aquadoc'
  s.version     = '1.0.0'
  s.date        = '2018-11-02'
  s.summary     = "A Documentation Generator for Aquarium Workflows"
  s.description = "Use this tool to publish your workflows!"
  s.authors     = ["Eric Klavins"]
  s.email       = 'klavins@uw.edu'
  s.files       = [
    "lib/aquadoc.rb",
    "lib/aquadoc/make.rb",
    "lib/aquadoc/render.rb",
    "lib/aquadoc/git.rb",
    "lib/assets/index.html.erb",
    "lib/aquadoc/version.rb",
    "lib/assets/aquadoc.css",
    "lib/assets/aquadoc.js",
    "lib/assets/yard_templates/default/onefile/html/layout.erb",
    "lib/assets/yard_templates/default/onefile/html/setup.rb",
    "lib/assets/ABOUT.md.erb",
    "lib/assets/operation_type.md.erb",
    "lib/assets/field_type.md.erb",
    "lib/assets/object_type.md.erb",
    "lib/assets/sample_type.md.erb",
    "lib/assets/DEFAULT_README.md",
    "lib/assets/DEFAULT_LICENSE.md",
    "lib/assets/nojekyll"
  ]
  s.add_runtime_dependency "yard", "0.9.16"
  s.add_runtime_dependency "octokit", "4.13.0"
  s.homepage    = 'http://klavinslab.org/protocols'
  s.license     = 'MIT'
  s.bindir      = 'bin'
  s.executables << 'aquadoc'
  s.post_install_message = "Thanks for installing Aquadoc!"
end
