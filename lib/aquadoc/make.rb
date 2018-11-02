#!/usr/bin/env ruby

require 'json'
require 'fileutils'
require './render.rb'

def sanitize_filename(filename)
  fn = filename.split /(?<=.)\.(?=[^.])(?!.*\.[^.])/m
  fn.map! { |s| s.gsub /[^a-z0-9\-]+/i, '_' }
  return fn.join '.'
end

# Define paths
base_path = "./" + ARGV[0]
src_path = "./src"
cat_path = base_path + "/categories/*.json"
html_path = base_path + "/html"
css_path = html_path + "/css"
js_path = html_path + "/js"
libraries_path = html_path + "/libraries"
operation_types_path = html_path + "/operation_types"
sample_types_path = html_path + "/sample_types"
object_types_path = html_path + "/object_types"

# Make directories
FileUtils.mkdir_p html_path
FileUtils.mkdir_p css_path
FileUtils.mkdir_p js_path
FileUtils.mkdir_p libraries_path
FileUtils.mkdir_p operation_types_path
FileUtils.mkdir_p sample_types_path
FileUtils.mkdir_p object_types_path

categories = []
sample_types = []
object_types = []
operation_type_specs = []
libraries = []

# Read in JSON category files and arrange the data into the above arrays
Dir[cat_path].each do |c|
  name = c.split("/").last;
  file = File.read(c);
  data = JSON.parse file, symbolize_names: true
  data.each do |object|
    if object[:library]
      libraries.push object[:library]
      categories.push object[:library][:category]
    else
      operation_type_specs.push object
      categories.push object[:operation_type][:category]
      object[:sample_types].each do |sample_type|
        sample_types.push sample_type
      end
      object[:object_types].each do |object_type|
        object_types.push object_type
      end
    end
  end
end

categories = categories.uniq.sort
sample_types = sample_types.uniq.sort_by { |st| st[:name] }
object_types = object_types.uniq.sort_by { |st| st[:name] }
libraries = libraries.sort_by { |lib| lib[:name] }
operation_type_specs = operation_type_specs.sort_by { |ots| ots[:operation_type][:name] }

# Make md files
categories.each do |c|
  operation_type_specs.select { |ots| ots[:operation_type][:category] == c }.each do |ots|
    File.write(operation_types_path + "/#{sanitize_filename ots[:operation_type][:name]}.md", op_type_md(ots))
  end
  libraries.select { |lib| lib[:category] == c }.each do |lib|
    File.write(libraries_path + "/#{sanitize_filename lib[:name]}.rb", lib[:code_source])
  end
end

sample_types.each do |st|
  File.write(sample_types_path + "/#{sanitize_filename st[:name]}.md", sample_type_md(st))
end

object_types.each do |ot|
  File.write(object_types_path + "/#{sanitize_filename ot[:name]}.md", object_type_md(ot))
end

# Generate index.html page
File.write(html_path + "/index.html", make_sidebar(categories, operation_type_specs, libraries, sample_types, object_types))

# Copy auxilliary files
FileUtils.copy(base_path + "/config.json", html_path + "/config.json")
FileUtils.copy(base_path + "/README.md", html_path + "/README.md")
FileUtils.copy(base_path + "/LICENSE.md", html_path + "/LICENSE.md")
FileUtils.copy(src_path + "/aquadoc.css", css_path + "/aquadoc.css")
FileUtils.copy(src_path + "/aquadoc.js",  js_path  + "/aquadoc.js")
FileUtils.copy(src_path + "/markdown-it.js",  js_path  + "/markdown-it.js")

# Make library docs
Dir.chdir libraries_path
system "touch README.md"
Dir["*.rb"].each do |lib|
  name = lib.split("/").last;
  hname = name.split(".")[0] + ".html"
  system "yardoc #{lib} --one-file"
  system "mv doc/index.html #{hname}"
end

system "rm -rf doc"
