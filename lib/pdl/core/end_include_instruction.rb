class EndIncludeInstruction < Instruction

  attr_reader :return_symbol, :return_value

  def initialize rsym, rval
    super 'end_include'
    @return_symbol = rsym
    @return_value = rval
    @renderable = false
  end

  def bt_execute scope, params
    eval_return_val = scope.evaluate return_value
    scope.pop
    scope.set return_symbol, eval_return_val
  end

  def html
    "<b>end include</b> (return #{return_symbol}=#{return_value})"
  end

end
