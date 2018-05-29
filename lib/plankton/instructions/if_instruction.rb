# frozen_string_literal: true

module Plankton

  class IfInstruction < Instruction

    attr_reader :end_then_pc, :then_pc, :else_pc

    def initialize(condition, options = {})
      @condition = condition
      super 'if', options
    end

    def mark_then(pc)
      @then_pc = pc
    end

    def mark_else(pc)
      @else_pc = pc
    end

    def mark_end_then(pc)
      @end_then_pc = pc
    end

    def adjust_offset(o)
      super o
      @then_pc += o
      @else_pc += o
      # @end_then_pc += o # legacy?
    end

    def set_pc(scope)
      if scope.evaluate @condition
        @then_pc
      else
        @else_pc
      end
    end

    def html
      "<b>if</b> #{@condition} <b>goto</b> #{@then_pc} <b>else goto</b> #{@else_pc} (end_then = #{@end_then_pc})"
    end

  end

end
