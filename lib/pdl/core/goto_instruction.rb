class GotoInstruction < Instruction

  attr_reader :destination

  def initialize(options = {})
    super 'goto', options
  end

  def mark_destination(dest)
    @destination = dest
  end

  def set_pc(_scope)
    @destination
  end

  def html
    "goto #{@destination}"
  end

end
