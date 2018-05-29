# frozen_string_literal: true

module Plankton

  class PopInstruction < Instruction

    def initialize(options = {})
      super 'pop', options
    end

    def bt_execute(scope, _params)
      scope.pop
    end

  end

end
