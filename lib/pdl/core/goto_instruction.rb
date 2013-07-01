class GotoInstruction < Instruction

  attr_reader :destination

  def initialize 
    super 'goto'
  end

  def mark_destination dest
    @destination = dest
  end

  def set_pc scope
    return @destination
  end

end
