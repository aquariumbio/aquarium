# frozen_string_literal: true

class StepInstruction < Instruction

  attr_reader :parts

  def initialize(part_exprs, options = {})

    @part_exprs = part_exprs
    @renderable = true
    super 'step', options

    # TERMINAL
    @parts = part_exprs

  end

  # RAILS #############################################################################################

  def description
    str = ''
    @parts.each do |a|
      str = a[:description] if a.key?(:description)
    end
    str
  end

  def note
    str = ''
    @parts.each do |a|
      str = a[:note] if a.key?(:note)
    end
    str
  end

  def image
    str = ''
    @parts.each do |a|
      str = "http://bioturk.ee.washington.edu:3012/bioturk/image?name=#{a[:image]}" if a.key?(:image)
    end
    str
  end

  def warnings
    w = []
    @parts.each do |a|
      w.push a[:warning] if a.key?(:warning)
    end
    w
  end

  def getdatas
    g = []
    @parts.each do |a|
      g.push a[:getdata] if a.key?(:getdata)
    end
    g
  end

  def selects
    g = []
    @parts.each do |a|
      g.push a[:select] if a.key?(:select)
    end
    g
  end

  def pre_render(scope, _params)

    @parts = []

    @part_exprs.each do |a|
      a.each do |k, v|
        begin
          if k == :getdata
            @parts.push(getdata: { var: v[:var], type: v[:type], description: scope.substitute(v[:description]) })
          elsif k == :select
            choice_evals = []
            v[:choices].each do |c|
              choice_evals.push scope.substitute c
            end
            @parts.push(select: { var: v[:var], description: scope.substitute(v[:description]), choices: choice_evals })
          else
            @parts.push(k => scope.substitute(v))
          end
        rescue Exception => e
          raise 'In <step>: ' + e.to_s
        end
      end
    end

  end

  def bt_execute(scope, params)

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
      log.data = { pc: @pc, getdatas: log_data }.to_json
      log.save
    end

  end

  def html
    '<b>step</b>: ' + description
  end

  # TERMINAL ##########################################################################################

  def render_description(d, scope)
    '  Description: ' + (scope.substitute d) + "\n"
  end

  def render_note(n, scope)
    '  Note: ' + (scope.substitute n) + "\n"
  end

  def render_warning(n, scope)
    '  !!!!Warning: ' + (scope.substitute n) + "!!!!\n"
  end

  def render_getdata(d, _scope)
    data_str = ''
    data_str += 'Please input data for the following inputs, respectively:'
    data_str += "\n Press Enter after each input >"
    data_str += "\n\t" + d[:var] + ': ' +  d[:description]
    data_str
  end

  def render(scope)

    @has_get_datas = false

    str = ''
    @parts.each do |a|

      str += render_description a[:description], scope if a.key?(:description)

      str += render_note a[:note], scope if a.key?(:note)

      str += render_warning a[:warning], scope if a.key?(:warning)

      if a.key?(:getdata)
        str += render_getdata a[:getdata], scope
        @has_get_datas = true
      end

    end

    puts eval ( '"' + str + '"') # Note, extra quotes for interpolation

    print "\nPress [ENTER] to continue: " unless @has_get_datas

  end

  def execute(scope)

    @parts.each do |a|
      scope.set a[:getdata][:var].to_sym, gets.chomp if a.key?(:getdata)
    end

    gets unless @has_get_datas

  end

end
