# frozen_string_literal: true

module Plankton

  class AssignInstruction < Instruction

    attr_reader :var, :value

    def initialize(lhs, rhs, options = {})
      super 'assign', options
      @lhs = lhs
      @rhs = rhs
      @renderable = false
      @new = if options[:new]
               options[:new]
             else
               false
             end
    end

    # RAILS ###########################################################################################

    def bt_execute(scope, _params)

      scope.set_complex @lhs, @rhs, @new
    rescue Exception => e
      raise "Could not assign #{@lhs} to #{@rhs}. " + e.to_s

    end

    def html
      "<b>assign</b> #{@lhs} = #{@rhs}"
    end

  end

end
