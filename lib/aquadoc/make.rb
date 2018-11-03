#!/usr/bin/env ruby

require 'json'
require 'fileutils'

class Aquadoc

  def sanitize_filename(filename)
    fn = filename.split /(?<=.)\.(?=[^.])(?!.*\.[^.])/m
    fn.map! { |s| s.gsub /[^a-z0-9\-]+/i, '_' }
    return fn.join '.'
  end

  def context
    self.instance_variables.map do |attribute|
      { attribute => self.instance_variable_get(attribute) }
    end
  end

  def assets_path_from_load_path

    paths = $LOAD_PATH.select { |p|
      p.match "aquadoc"
    }
    if paths.length == 1
      paths[0]
    else
      raise "Could not find aquadoc assets directory in #{$LOAD_PATH}"
    end

  end

  def define_paths

    @base_path = Dir.pwd
    @categories_path = @base_path + "/categories"
    @categories_directory = @categories_path + "/*.json"

    @html_path = @base_path + "/html"
    @css_path = @html_path + "/css"
    @js_path = @html_path + "/js"
    @libraries_path = @html_path + "/libraries"
    @operation_types_path = @html_path + "/operation_types"
    @sample_types_path = @html_path + "/sample_types"
    @object_types_path = @html_path + "/object_types"

    @config_path = @base_path + "/config.json"

    @assets_path = assets_path_from_load_path + "/assets"

  end

  def make_directories

    FileUtils.mkdir_p @html_path
    FileUtils.mkdir_p @css_path
    FileUtils.mkdir_p @js_path
    FileUtils.mkdir_p @libraries_path
    FileUtils.mkdir_p @operation_types_path
    FileUtils.mkdir_p @sample_types_path
    FileUtils.mkdir_p @object_types_path

  end

  def make_parts

    @categories = []
    @sample_types = []
    @object_types = []
    @operation_type_specs = []
    @libraries = []

    # Read in JSON category files and arrange the data into the above arrays
    puts "Reading categories: #{@categories_directory}"
    Dir[@categories_directory].each do |c|
      puts "c = #{c}"
      name = c.split("/").last;
      file = File.read(c);
      data = JSON.parse file, symbolize_names: true
      data.each do |object|
        if object[:library]
          @libraries.push object[:library]
          @categories.push object[:library][:category]
        else
          @operation_type_specs.push object
          @categories.push object[:operation_type][:category]
          object[:sample_types].each do |sample_type|
            @sample_types.push sample_type
          end
          object[:object_types].each do |object_type|
            @object_types.push object_type
          end
        end
      end
    end

    @categories = @categories.uniq.sort
    @sample_types = @sample_types.uniq.sort_by { |st| st[:name] }
    @object_types = @object_types.uniq.sort_by { |st| st[:name] }
    @libraries = @libraries.sort_by { |lib| lib[:name] }
    @operation_type_specs = @operation_type_specs.sort_by { |ots| ots[:operation_type][:name] }

  end

  def make_md

    @categories.each do |c|
      @operation_type_specs.select { |ots| ots[:operation_type][:category] == c }.each do |ots|
        File.write(@operation_types_path + "/#{sanitize_filename ots[:operation_type][:name]}.md", op_type_md(ots))
      end
      @libraries.select { |lib| lib[:category] == c }.each do |lib|
        File.write(@libraries_path + "/#{sanitize_filename lib[:name]}.rb", lib[:code_source])
      end
    end

    @sample_types.each do |st|
      File.write(@sample_types_path + "/#{sanitize_filename st[:name]}.md", sample_type_md(st))
    end

    @object_types.each do |ot|
      File.write(@object_types_path + "/#{sanitize_filename ot[:name]}.md", object_type_md(ot))
    end

  end

  def make_yard_docs

    Dir.chdir @libraries_path
    unless system "touch README.md"
      raise "Could not write to #{@temp_dir}"
    end
    Dir["./*.rb"].each do |lib|
      name = lib.split("/").last;
      hname = name.split(".")[0] + ".html"
      unless system "yardoc -p #{@assets_path}/yard_templates #{lib} --one-file --quiet"
        raise "Could not run yardoc on #{lib}"
      end
      unless system "mv doc/index.html #{hname}"
        raise "Could not move doc file for #{hname}"
      end
    end

    system "rm -rf doc"

    Dir.chdir @base_path

  end

  def copy_assets
    FileUtils.copy(@base_path + "/config.json",     @html_path + "/config.json")
    FileUtils.copy(@base_path + "/README.md",       @html_path + "/README.md")
    FileUtils.copy(@base_path + "/LICENSE.md",      @html_path + "/LICENSE.md")
    FileUtils.copy(@assets_path + "/aquadoc.css",   @css_path  + "/aquadoc.css")
    FileUtils.copy(@assets_path + "/aquadoc.js",    @js_path   + "/aquadoc.js")
  end

  def make_about_md

    @config

    str = <<~MD
      # #{@config[:title]}, version #{@config[:version]}
      #{@config[:description]}
      
      [#{@config[:repo]}](#{@config[:repo]})

      &copy; #{@config[:copyright]}

      ### Maintainer
      - #{@config[:maintainer][:name]}, <#{@config[:maintainer][:email]}>

      ### Authors
      #{@config[:authors].collect { |a| "- #{a}"}.join("\n")}

      ### Acknowledgements
      #{@config[:acknowledgements].collect { |a| "- #{a}"}.join("\n")}

      ### Details
      These documents were automatically generated from [Aquarium](http://klavinslab.org)
      categories using [aquadoc](https://github.com/klavinslab/aquadoc).
    MD

    File.write(@html_path + "/ABOUT.md",str)

  end

  def read_config

    default_config = {
      title: "No title specified",
      description: "No description given",
      copyright: "No copyright declared",
      version: "no version info",
      authors: [],
      maintainer: {
    	  name: "No maintainer",
    	  email: "noone@nowehere"
      },
      acknowledgements: [],
      repo: "no repository specified"
    }

    begin
      file = File.read(@config_path)
    rescue Exception => e
      raise "Could not find config file at #{@config_path}"
    end
    begin
      json = JSON.parse(file, symbolize_names: true)
    rescue Exception => e
      raise "Could not parse config file: #{e}"
    end

    @config = default_config.merge(json)

  end

  def make
    define_paths
    read_config
    make_directories
    make_parts
    make_md
    make_about_md
    make_sidebar
    copy_assets
    make_yard_docs
  end

end
