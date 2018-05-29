# frozen_string_literal: true

module Plankton

  class WhileInstruction < Instruction

    attr_reader :true_pc, :false_pc

    def initialize(condition, tpc, options = {})
      @condition = condition
      @true_pc = tpc
      super 'while', options
    end

    def mark_false(pc)
      @false_pc = pc
    end

    def adjust_offset(o)
      super o
      @true_pc += o
      @false_pc += o
    end

    def set_pc(scope)
      if scope.evaluate @condition
        @true_pc
      else
        @false_pc
      end
    end

  end

end
