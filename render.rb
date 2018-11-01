def sample_type_link name
  "<a href='#' onclick='load_sample_type(\"#{sanitize_filename name}\")'>#{name}</a>"
end

def object_type_link name
  "<a href='#' onclick='load_object_type(\"#{sanitize_filename name}\")'>#{name}</a>"
end

def op_type_md operation_type_spec
  operation_type_spec[:operation_type][:name] + "\n" +
   "===\n" +
   operation_type_spec[:operation_type][:documentation]
end

#
# Render a sample type
#
def sample_type_md sample_type

  str = sample_type[:name] + "\n" +
        "===\n" +
        sample_type[:description] + "\n\n"

  sample_type[:field_types].each do |ft|
    if ft[:ftype] == 'sample'
      str += "- **#{ft[:name]}:** "
      str += ft[:allowable_field_types].collect { |aft| aft[:sample_type] ? sample_type_link(aft[:sample_type][:name]) : "?" }.join(", ") + "\n"
    else
      str += "- **#{ft[:name]}:** #{ft[:ftype]}\n"
    end
  end

  # str += "```json\n" +
  #        JSON.pretty_generate(sample_type, space: '    ', space_before: '        ') + "\n" +
  #        "```"

  str

end

#
# Render an objec type / container
#
def object_type_md object_type

  str = object_type[:name] + "\n" +
        "===\n" +
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

  # str += "```json\n" +
  #        JSON.pretty_generate(object_type) + "\n" +
  #        "```"

  str

end

def make_sidebar categories, operation_type_specs, libraries, sample_types, object_types

  html = "<ul class='list-unstyled'>\n"
  html += "<li><a href='#' onclick='load_overview()'>Overview</a></li>\n"

  categories.each do |c|
    html += "  <li><b>#{c}</b>\n"
    html += "    <ul>\n"
    operation_type_specs.select { |ots| ots[:operation_type][:category] == c }.each do |ots|
      html += "      <li><a href='#' onclick='load_operation_type(\"#{sanitize_filename ots[:operation_type][:name]}\")'>#{ots[:operation_type][:name]}</a></li>\n"
    end
    libraries.select { |lib| lib[:category] == c }.each do |lib|
      html += "      <li>Library: <a href='#' onclick='load_library(\"#{sanitize_filename lib[:name]}\")'>#{lib[:name]}</a></li>\n"
    end
    html += "    </ul>\n"
    html += "  </li>\n"
  end

  html += "  <li><b>Sample Types</b>\n"
  html += "    <ul>\n"
  sample_types.each do |st|
    html +=  "      <li><a href='#' onclick='load_sample_type(\"#{sanitize_filename st[:name]}\")'>#{st[:name]}</a></li>\n"
  end
  html += "    </ul>\n"
  html += "  </li>\n"

  html += "  <li><b>Containers</b>\n"
  html += "    <ul>\n"
  object_types.each do |ot|
    html +=  "      <li><a href='#' onclick='load_object_type(\"#{sanitize_filename ot[:name]}\")'>#{ot[:name]}</a></li>\n"
  end
  html += "    </ul>\n"
  html += "  </li>\n"

  html += "</ul>\n"

  part1 = file = File.read("src/index_part_1.html");
  part2 = file = File.read("src/index_part_2.html");

  part1 + html + part2;

end
