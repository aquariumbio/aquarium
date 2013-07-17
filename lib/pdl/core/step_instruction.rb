class StepInstruction < Instruction

  attr_reader :parts

  def initialize part_exprs

    @part_exprs = part_exprs
    @renderable = true
    super 'step'

    # TERMINAL
    @parts = part_exprs

  end

  # RAILS #############################################################################################

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

  def selects
    g = []
    @parts.each do |a|
      g.push a[:select] if a.has_key?(:select)
    end
    g
  end

  def pre_render scope, params

    @parts = []

    @part_exprs.each do |a|
      a.each do |k,v|
        begin
          if k == :getdata
            @parts.push( getdata: { var: v[:var], type: v[:type], description: scope.substitute( v[:description] ) } )
          elsif k == :select
            choice_evals = []
            v[:choices].each do |c|
              choice_evals.push scope.substitute c
            end
            @parts.push( select: { var: v[:var], description: scope.substitute( v[:description] ), choices: choice_evals } )
          else
            @parts.push( k => scope.substitute( v ) )
          end
        rescue Exception => e
          raise "In <step>: " + e.to_s
        end
      end
    end

  end

  def bt_execute scope, params

    log_data = {}

    getdatas.each do |g|
      sym = g[:var].to_sym
      if g[:type] == 'number' && params[g[:var]].to_i == params[g[:var]].to_f
        scope.set sym, params[g[:var]].to_i
      elsif g[:type] == 'number'
        scope.set sym, params[g[:var]].to_f
      else
        scope.set sym, params[g[:var]]
      end
      log_data[sym] = scope.get sym
    end

    selects.each do |s|
      sym = s[:var].to_sym
      scope.set sym, params[s[:var]]
      log_data[sym] = scope.get sym
    end

    unless log_data.empty?
      log = Log.new
      log.job_id = params[:job]
      log.user_id = scope.stack.first[:user_id]
      log.entry_type = 'GETDATA'
      log.data = {pc: @pc, getdatas: log_data}.to_json
      log.save
    end

  end

  # TERMINAL ##########################################################################################

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
