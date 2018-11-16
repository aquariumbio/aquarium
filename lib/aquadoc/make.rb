#!/usr/bin/env ruby

require 'json'
require 'fileutils'

module Aquadoc

  class Render

    attr_accessor :html_path

    def sanitize_filename(filename)
      if filename
        fn = filename.split /(?<=.)\.(?=[^.])(?!.*\.[^.])/m
        fn.map! { |s| s.gsub /[^a-z0-9\-]+/i, '_' }
        return fn.join '.'
      else
        "nil"
      end
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
      @html_path = @base_path + "/" + @config[:github][:repo]
      @temp_library_path = @base_path + "/temp_library_path"
      @config_path = @base_path + "/config.json"
      @assets_path = assets_path_from_load_path + "/assets"
    end

    def make_directories
      FileUtils.mkdir_p @temp_library_path
    end

    def make_parts

      @categories = []
      @sample_types = []
      @object_types = []
      @operation_type_specs = []
      @libraries = []

      # Read in JSON category files and arrange the data into the above arrays
      @category_list.each do |data|
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
        if @options[:workflows]
          @operation_type_specs.select { |ots| ots[:operation_type][:category] == c }.each do |ots|
            @storage.write("operation_types/#{sanitize_filename ots[:operation_type][:name]}.md", op_type_md(ots))
          end
        end
        if @options[:libraries]
          @libraries.select { |lib| lib[:category] == c }.each do |lib|
            File.write(@temp_library_path + "/#{sanitize_filename lib[:name]}.rb", lib[:code_source])
            @storage.write("libraries/#{sanitize_filename lib[:name]}.rb", lib[:code_source])
          end
        end
      end

      if @options[:inventory]
        @sample_types.each do |st|
          @storage.write("sample_types/#{sanitize_filename st[:name]}.md", sample_type_md(st))
        end

        @object_types.each do |ot|
          @storage.write("object_types/#{sanitize_filename ot[:name]}.md", object_type_md(ot))
        end
      end

    end

    def make_yard_docs

      puts "Making yard docs"

      Dir.chdir @temp_library_path
      unless system "touch README.md"
        raise "Could not write to #{@temp_dir}"
      end

      Dir["./*.rb"].each do |lib|
        name = lib.split("/").last;
        hname = name.split(".")[0] + ".html"
        unless system "yardoc -p #{@assets_path}/yard_templates #{lib} --one-file --quiet"
          raise "Could not run yardoc on #{lib}"
        end
        @storage.write("libraries/#{hname}", File.read("doc/index.html"))
        system "rm doc/index.html"
      end

      system "rm -rf doc"
      system "rm -rf #{@temp_library_path}"

      Dir.chdir @base_path

    end

    def zipname
      @config[:github][:repo] + ".aq"
    end

    def copy_assets

      if @options[:init]
        @storage.write("README.md", File.read(@assets_path + "/DEFAULT_README.md"))
        @storage.write("LICENSE.md", File.read(@assets_path + "/DEFAULT_LICENSE.md"))
      end

      @storage.write("css/aquadoc.css", File.read(@assets_path + "/aquadoc.css"))
      @storage.write("js/aquadoc.js", File.read(@assets_path + "/aquadoc.js"))
      @storage.write(".nojekyll", File.read(@assets_path + "/nojekyll"))
      @storage.write(zipname, @category_list.to_json)

      @config[:github].delete(:access_token)
      @storage.write("config.json", @config.to_json)

    end

    def initialize storage, config, category_list

      @storage = storage
      @category_list = JSON.parse(category_list.to_json, symbolize_names: true)

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
        github: {
          repo: "none",
          user: "none",
          access_token: "none"
        },
        keywords: [],
        aquadoc_version: Aquadoc.version
      }

      konfig = JSON.parse(config.to_json, symbolize_names: true)
      @config = default_config.merge(konfig)

      define_paths

    end

    def cleanup
      FileUtils.rm_rf(@html_path)
    end

    def make opts={}

      @options = {
          inventory: true,
          libraries: true,
          workflows: true,
          yard_docs: true,
          init: true
      }.merge opts

      make_directories
      make_parts
      make_md
      make_about_md
      make_index
      make_yard_docs if @options[:yard_docs] && @options[:libraries]
      copy_assets

    end

  end

end
