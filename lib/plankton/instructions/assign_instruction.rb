module Plankton

  class AssignInstruction < Instruction

    attr_reader :var, :value

    def initialize lhs, rhs, options = {}
      super 'assign', options
      @lhs = lhs
      @rhs = rhs
      @renderable = false
    end

    # RAILS ###########################################################################################

    def bt_execute scope, params
      scope.set( @lhs.to_sym, scope.evaluate( @rhs ) )
    end

    def html
      "<b>assign</b> #{@lhs} = #{@rhs}"
    end

  end

end
