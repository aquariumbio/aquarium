class ArgumentInstruction < Instruction

  attr_reader :var, :type, :description

  def initialize name, type, description
    super 'argument'
    @name = name
    @type = type
    @description = description
  end

end
