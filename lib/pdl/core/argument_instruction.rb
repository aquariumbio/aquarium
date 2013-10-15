class ArgumentInstruction < Instruction

  attr_reader :var, :type, :description

  def initialize name, type, description, options = {}
    super 'argument', options
    @name = name
    @type = type
    @description = description
  end

end
