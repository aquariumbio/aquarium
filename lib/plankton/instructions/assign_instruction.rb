module Plankton

  class AssignInstruction < Instruction

    attr_reader :var, :value

    def initialize lhs, rhs, options = {}
      super 'assign', options
      @lhs = lhs
      @rhs = rhs
      @renderable = false
      if options[:new]
        @new = options[:new]
      else
        @new = false
      end
    end

    # RAILS ###########################################################################################

    def bt_execute scope, params

      puts "Assign #{@lhs} = #{@rhs} with scope.methods with sqrt(2) = #{scope.sqrt(2)}"

      scope.set_complex @lhs, @rhs, @new

    end

    def html
      "<b>assign</b> #{@lhs} = #{@rhs}"
    end

  end

end
