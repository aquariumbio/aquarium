class StartIncludeInstruction < Instruction

  attr_reader :arguments, :filename

  def initialize args, file, sha
    super 'start_include'
    @arguments = args
    @filename = file
    @renderable = false
    @sha = sha
  end

  def bt_execute scope, params

    eval_args = []

    arguments.each do |a|
      eval_args.push({ var: a[:var], value: eval(scope.substitute a[:value]) })
    end
    scope.push
    arguments.each do |a|
      scope.set a[:var].to_sym, eval(scope.substitute a[:value])
    end

    log = Log.new
    log.job_id = params[:job]
    log.user_id = scope.stack.first[:user_id]
    log.entry_type = 'INCLUDE'
    log.data = { pc: @pc, file: @filename, sha: @sha }.to_json
    log.save
    
  end

  def to_html
    "start include " + @filename
  end

end
