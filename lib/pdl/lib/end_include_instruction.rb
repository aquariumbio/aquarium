class EndIncludeInstruction < Instruction

  attr_reader :return_symbol, :return_value

  def initialize rsym, rval
    super 'end_include'
    @return_symbol = rsym
    @return_value = rval
  end

  def execute scope
    eval_return_val = eval(scope.substitute return_value)
    scope.pop
    scope.set return_symbol, eval_return_val
    puts "debug: scope is now:"
    puts scope.to_s
  end

end
