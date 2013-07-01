class ArgumentInstruction < Instruction

  attr_reader :var, :description

  def initialize var, description
    super 'argument'
    @var = var
    @description = description
  end

end
