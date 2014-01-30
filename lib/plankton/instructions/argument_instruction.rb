module Plankton

  class ArgumentInstruction < Instruction

    attr_reader :var, :type, :description
    attr_accessor :sample_type

    def initialize name, type, description, options = {}
      super 'argument', options
      @name = name
      @type = type
      @description = description
      @sample_type = ""
    end

  end

end
