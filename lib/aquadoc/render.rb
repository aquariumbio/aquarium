require 'erb'

module Aquadoc
  class Render
    def sample_type_link name
      if @options[:inventory] && name
        "<a href='#' onclick='easy_select(\"Sample Types\", \"#{name}\")'>#{name}</a>"
      elsif !@options[:inventory] && name
        name
      else
        "NO SAMPLE TYPE"
      end
    end

    def object_type_link name
      if @options[:inventory] && name
        "<a href='#' onclick='easy_select(\"Containers\", \"#{name}\")'>#{name}</a>"
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
      index = File.read(@assets_path + "/index.html")
      @storage.write("index.html", index)
    end

    def make_js
      # definitions
      template = File.read(@assets_path + "/definitions.js.erb")
      template_erb = ERB.new(template, 0, "%<>")
      @storage.write("js/definitions.js", template_erb.result(binding))

      # # aqauverse.js
      # @storage.write("js/aquaverse.js", File.read(@assets_path + "/aquaverse.js"))
      #
      # # highlight.js
      # @storage.write("js/highlight.js", File.read(@assets_path + "/highlight.js"))
    end
  end
end
