class Aquadoc

  def sample_type_link name
    if name
      "<a href='#' onclick='load_sample_type(\"#{
        sanitize_filename name
      }\")'>#{name}</a>"
    else
      "NO SAMPLE TYPE"
    end
  end

  def object_type_link name
    if name
      "<a href='#' onclick='load_object_type(\"#{
        sanitize_filename name
      }\")'>#{name}</a>"
    else
      "NO CONTAINER"
    end
  end

  def field_type_md ft
    str  = "- **#{ft[:name]}**"
    str += " [#{ft[:routing]}]"
    str += " (Array)" if ft[:array]
    str += " Part of collection" if ft[:part]
    str += "\n"
    ft[:sample_types].zip(ft[:object_types]).each do |st,ot|
      str += "  - " + sample_type_link(st) +
             " / " + object_type_link(ot) + "\n"
    end
    str
  end

  def op_type_md operation_type_spec

    ot = operation_type_spec[:operation_type]

    str = "# " + ot[:name]    + "\n\n" +
          ot[:documentation] + "\n\n"

    inputs = ot[:field_types].select { |ft| ft[:role] == 'input' && ft[:ftype] == 'sample' }
    params = ot[:field_types].select { |ft| ft[:role] == 'input' && ft[:ftype] != 'sample' }
    outputs = ot[:field_types].select { |ft| ft[:role] == 'output' && ft[:ftype] == 'sample' }

    str += "### Inputs\n\n" unless inputs.empty?

    inputs.each do |input|
      str += field_type_md input
    end

    str += "### Parameters\n\n" unless params.empty?

    params.each do |p|
      str += "- **#{p[:name]}**"
      str += " [#{p[:choices]}]" if p[:choices]
      str += "\n"
    end

    str += "### Outputs\n\n" unless outputs.empty?

    outputs.each do |output|
      str += field_type_md output
    end

    str += "### Precondition <a href='#' id='precondition'>[show]</a>\n"
    str += "```ruby\n#{ot[:precondition]}\n```\n"

    str += "### Protocol Code <a href='#' id='protocol'>[show]</a>\n"
    str += "```ruby\n#{ot[:protocol]}\n```\n"

    str

  end

  #
  # Render a sample type
  #
  def sample_type_md sample_type

    str = "# Sample Type: " + sample_type[:name] + "\n" +
          sample_type[:description] + "\n\n"

    if sample_type[:field_types]
      sample_type[:field_types].each do |ft|
        if ft[:ftype] == 'sample'
          str += "- **#{ft[:name]}:** "
          str += ft[:allowable_field_types].collect { |aft|
            aft[:sample_type] ?
            sample_type_link(aft[:sample_type][:name]) :
            "?" }.join(", ") + "\n"
        else
          str += "- **#{ft[:name]}:** #{ft[:ftype]}\n"
        end
      end
    end

    str

  end

  #
  # Render an objec type / container
  #
  def object_type_md object_type

    str = "# Container: " + object_type[:name] + "\n" +
          object_type[:description] + "\n\n"

    if object_type[:handler] == 'collection'
      str += "#{object_type[:rows]} &times; #{object_type[:columns]} Collection\n\n"
    end

    if object_type[:handler] == 'sample_container' && object_type[:sample_type_name]
      str += "**contains:** " + sample_type_link(object_type[:sample_type_name]) + "\n\n"
    end

    if object_type[:handler] == 'sample_container' && !object_type[:sample_type_name]
      str += "**Warning:** This container is marked as a sample comtainer, but has no link to a sample type.\n\n"
    end

    str

  end

  def make_sidebar

    html = "<ul class='list-unstyled'>\n"
    html += "<li><b>Overview</b>\n"
    html += "  <ul>\n"
    html += "    <li><a href='#' onclick='load_overview()'>Introduction</a></li>\n"
    html += "    <li><a href='#' onclick='load_about()'>About this Workflow</a></li>\n"
    html += "    <li><a href='#' onclick='load_license()'>License</a></li>\n"
    html += "  </ul>"

    @categories.each do |c|
      html += "  <li><b>#{c}</b>\n"
      html += "    <ul>\n"
      @operation_type_specs.select { |ots| ots[:operation_type][:category] == c }
                           .each do |ots|
        html += "      " +
                "<li><a href='#' onclick='load_operation_type(\"#{
                  sanitize_filename ots[:operation_type][:name]
                }\")'>#{ots[:operation_type][:name]}</a></li>\n"
      end
      @libraries.select { |lib| lib[:category] == c }.each do |lib|
        html += "      " +
                "<li>Library: <a href='#' onclick='load_library(\"#{
                  sanitize_filename lib[:name]
                }\")'>#{lib[:name]}</a></li>\n"
      end
      html += "    </ul>\n"
      html += "  </li>\n"
    end

    html += "  <li><b>Sample Types</b>\n"
    html += "    <ul>\n"
    @sample_types.each do |st|
      html +=  "      " +
               "<li><a href='#' onclick='load_sample_type(\"#{
                 sanitize_filename st[:name]
               }\")'>#{st[:name]}</a></li>\n"
    end
    html += "    </ul>\n"
    html += "  </li>\n"

    html += "  <li><b>Containers</b>\n"
    html += "    <ul>\n"
    @object_types.each do |ot|
      html +=  "      " +
               "<li><a href='#' onclick='load_object_type(\"#{
                 sanitize_filename ot[:name]
               }\")'>#{ot[:name]}</a></li>\n"
    end
    html += "    </ul>\n"
    html += "  </li>\n"

    html += "</ul>\n"

    part1 = file = File.read(@assets_path + "/index_part_1.html");
    part2 = file = File.read(@assets_path + "/index_part_2.html");

    File.write(@html_path + "/index.html", part1 + html + part2);

  end

end
