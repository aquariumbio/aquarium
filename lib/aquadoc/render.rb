require 'erb'

module Aquadoc

  class Render

    def sample_type_link name
      if @options[:inventory] && name
        "<a href='#' onclick='load_sample_type(\"#{
          sanitize_filename name
        }\")'>#{name}</a>"
      elsif !@options[:inventory] && name
        name
      else
        "NO SAMPLE TYPE"
      end
    end

    def object_type_link name
      if @options[:inventory] && name
        "<a href='#' onclick='load_object_type(\"#{
          sanitize_filename name
        }\")'>#{name}</a>"
      elsif !@options[:inventory] && name
        name
      else
        "NO CONTAINER"
      end
    end

    def field_type_md ft

      template = File.read(@assets_path + "/field_type.md.erb")
      template_erb = ERB.new(template, 0, "%<>")
      template_erb.result(binding)

    end

    def op_type_md operation_type_spec

      ot = operation_type_spec[:operation_type]
      inputs = ot[:field_types].select { |ft| ft[:role] == 'input' && ft[:ftype] == 'sample' }
      params = ot[:field_types].select { |ft| ft[:role] == 'input' && ft[:ftype] != 'sample' }
      outputs = ot[:field_types].select { |ft| ft[:role] == 'output' && ft[:ftype] == 'sample' }

      template = File.read(@assets_path + "/operation_type.md.erb")
      template_erb = ERB.new(template, 0, "%<>")
      template_erb.result(binding)

    end

    def sample_type_md sample_type

      template = File.read(@assets_path + "/sample_type.md.erb")
      template_erb = ERB.new(template, 0, "%<>")
      template_erb.result(binding)

    end

    def object_type_md object_type

      template = File.read(@assets_path + "/object_type.md.erb")
      template_erb = ERB.new(template, 0, "%<>")
      template_erb.result(binding)

    end

    def make_about_md

      template = File.read(@assets_path + "/ABOUT.md.erb")
      template_erb = ERB.new(template, 0, "%<>")
      @storage.write("ABOUT.md", template_erb.result(binding))

    end

    def make_index

      template = File.read(@assets_path + "/index.html.erb")
      template_erb = ERB.new(template, 0, "%<>")
      @storage.write("index.html", template_erb.result(binding))

    end

    def make_js

      template = File.read(@assets_path + "/aquadoc.js.erb")
      template_erb = ERB.new(template, 0, "%<>")
      @storage.write("js/aquadoc.js", template_erb.result(binding))

    end

  end

end
