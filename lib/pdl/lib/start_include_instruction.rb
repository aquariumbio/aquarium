class StartIncludeInstruction < Instruction

  attr_reader :arguments, :filename

  def initialize args, file
    super 'start_include'
    @arguments = args
    @filename = file
  end

  def execute scope

    eval_args = []

    arguments.each do |a|
      eval_args.push({ var: a[:var], value: eval(scope.substitute a[:value]) })
    end
    scope.push
    arguments.each do |a|
      scope.set a[:var].to_sym, eval(scope.substitute a[:value])
    end
    
  end

end
