module Plankton

  class PushInstruction < Instruction

    def initialize options = {}
      super 'push', options
    end

    def bt_execute scope, params
      scope.push
    end

  end

end
