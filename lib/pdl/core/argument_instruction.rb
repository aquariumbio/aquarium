class ArgumentInstruction < Instruction

  attr_reader :var, :type, :description

  def initialize var, type, description
    super 'argument'
    @var = var
    @type = type
    @description = description
  end

end
