namespace :docs do

  desc 'Generate publicly accessible documentation'

  md = [
    "Krill",
    "API",
    "Installation",
    "Location Wizard",
    "Folders",
    "Reference",
    "Oyster",
    "DataAssociation",
    "Operations",
    "Data Structures",
    "Operation Lifetime",
    "BugReportStyle"
  ]

  task :md do 
    puts "copying doc/*.md files to public/doc/md"
    sh "rm -rf public/doc/md"    
    sh "mkdir public/doc/md"
    md.each do |name|
      sh "cp 'doc/#{name}.md' public/doc/md"
    end
    sh "cp -r doc/images public/doc"
  end

  task :auto do
    puts "Autogenerating yard docs"
    sh "rm -rf public/doc/autodocs"
    sh "mkdir public/doc/autodocs"    
    sh "yardoc"
    sh "mv ./doc/api public/doc/autodocs"
  end

end
