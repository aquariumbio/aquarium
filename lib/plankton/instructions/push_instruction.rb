# frozen_string_literal: true

module Plankton

  class PushInstruction < Instruction

    def initialize(options = {})
      super 'push', options
    end

    def bt_execute(scope, _params)
      scope.push
    end

  end

end
