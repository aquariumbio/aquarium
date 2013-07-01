class IfInstruction < Instruction

  attr_reader :end_then_pc, :then_pc, :else_pc

  def initialize condition
    @condition = condition
    super 'if'
  end

  def mark_then pc
    @then_pc = pc
  end

  def mark_else pc
    @else_pc = pc
  end

  def mark_end_then pc
    @end_then_pc = pc
  end

  def set_pc scope
    if scope.evaluate @condition
      return @then_pc
    else
      return @else_pc
    end
  end

end
