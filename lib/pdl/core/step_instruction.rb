class StepInstruction < Instruction

  attr_reader :parts

  # argument should be a hash as in [ description: string, ...]
  def initialize parts
    super 'step'
    @parts = parts
  end

  def render_description d, scope 
    return "  Description: " +  (scope.substitute d) + "\n"
  end

  def render_note n, scope
    return "  Note: " + (scope.substitute n) + "\n"
  end

  def render_warning n, scope
    return "  !!!!Warning: " + (scope.substitute n) + "!!!!\n"
  end

  def render_getdata d, scope
    data_str = ""
    data_str += "Please input data for the following inputs, respectively:"
    data_str += "\n Press Enter after each input >"
    data_str += "\n\t" + d[:var] + ": " +  d[:description]
    return data_str
  end  

  def render scope

    @has_get_datas = false

    str = ""
    @parts.each do |a|
        
        if a.has_key?(:description)
          str += render_description a[:description], scope
	end

        if a.has_key?(:note)
          str += render_note a[:note], scope
	end
 
        if a.has_key?(:warning)
	  str += render_warning a[:warning], scope
	end

	if a.has_key?(:getdata)
	  str += render_getdata a[:getdata], scope
          @has_get_datas = true
	end

    end

    puts eval ( "\"" + str + "\"" ) # Note, extra quotes for interpolation

    print "\nPress [ENTER] to continue: " unless @has_get_datas


  end

  def execute scope
   
    @parts.each do |a|
        if a.has_key?(:getdata)
	  scope.set a[:getdata][:var].to_sym, gets.chomp
        end
    end
    
    unless @has_get_datas
      gets
    end
  
  end

end
