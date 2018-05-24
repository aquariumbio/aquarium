class InformationInstruction
  def to_html
    @content.to_s
  end
end

class TakeInstruction
  def to_html
    @item_list_expr.to_s
  end
end

class ReleaseInstruction
  def to_html
    "Put #{@expr} away."
  end
end

class ProduceInstruction
  def to_html
    "Store #{@object_type_name} #{@location}."
  end
end

class AssignInstruction
  def to_html
    "#{@lhs} := #{@rhs}"
  end
end

class StepInstruction
  def to_html
    str = ''
    @parts.each do |p|
      case p.keys.first
      when :description
        str += (p[:description]).to_s
      when :note
        str += "<span class='note'>Note: #{p[:note]}</span>"
      when :getdata
        str += "<span class='getdata'>Input: <i>#{p[:getdata][:var]}</i>: #{p[:getdata][:description]}.</span>"
      end
    end
    str
  end
end

class IfInstruction
  def to_html
    "<span class='note'>#{@condition}</span>"
  end
end

class WhileInstruction
  def to_html
    "<span class='note'>#{@condition}</span>"
  end
end

class GotoInstruction
  def to_html
    @destination.to_s
  end
end

class LogInstruction
  def to_html
    "<i>#{@type}</i>: #{data}"
  end
end
