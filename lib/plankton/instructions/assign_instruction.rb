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
      puts "EXECUTING ASSIGN WITH new = #{@new}: #{@lhs} = #{@rhs}"
      if @new
        scope.set_new( @lhs.to_sym, scope.evaluate( @rhs ) )
      else
        scope.set( @lhs.to_sym, scope.evaluate( @rhs ) )
      end
    end

    def html
      "<b>assign</b> #{@lhs} = #{@rhs}"
    end

  end

end
