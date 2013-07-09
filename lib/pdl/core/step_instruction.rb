class StepInstruction < Instruction

  attr_reader :parts

  # argument should be a hash as in [ description: string, ...]
  def initialize parts
    super 'step'
    @parts = parts
    @renderable = true
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

  def bt_execute scope, params

    # all get_datas should be in the parameters
    params.each do |k,v|
      if k != 'job'
        scope.set k.to_sym, v
      end
    end

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

  def description 
    str = ""
    @parts.each do |a|
      str = a[:description] if a.has_key?(:description)
    end
    str
  end

  def note
    str = ""
    @parts.each do |a|
      str = a[:note] if a.has_key?(:note)
    end
    str
  end

  def warnings
    w = []
    @parts.each do |a|
      w.push a[:warning] if a.has_key?(:warning)
    end
    w
  end

  def getdatas
    g = []
    @parts.each do |a|
      g.push a[:getdata] if a.has_key?(:getdata)
    end
    g
  end

  def pre_render scope, params
    newparts = []
    @parts.each do |a|
      a.each do |k,v|
        begin
          if k != :getdata
            newparts.push( k => scope.substitute( v ) )
          else
            newparts.push( getdata: { var: v[:var], description: scope.substitute( v[:description] ) } )
          end
        rescue Exception => e
          raise "In <step>: " + e.to_s
        end
      end
    end
    @parts = newparts
  end

end
