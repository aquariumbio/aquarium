class WhileInstruction < Instruction

  attr_reader :true_pc, :false_pc

  def initialize condition, tpc
    @condition = condition
    @true_pc = tpc
    super 'while'
  end

  def mark_false pc
    @false_pc = pc
  end

  def set_pc scope
    if scope.evaluate @condition
      return @true_pc
    else
      return @false_pc
    end
  end

end
