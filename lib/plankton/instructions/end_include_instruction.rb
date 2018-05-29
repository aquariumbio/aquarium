# frozen_string_literal: true

module Plankton

  class EndIncludeInstruction < Instruction

    attr_reader :returns

    def initialize(rets, options = {})
      super 'end_include', options
      @returns = rets
      @renderable = false
    end

    def bt_execute(scope, _params)

      evals = {}

      @returns.each do |var, expr|
        evals[var] = scope.evaluate expr
        puts "***************Returning #{var} = #{evals[var]}"
      end

      scope.pop

      evals.each do |var, val|
        scope.set var.to_sym, val
      end

    end

    def html
      "<b>end include</b> (return #{returns})"
    end

  end

end
