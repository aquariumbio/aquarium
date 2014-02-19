module Plankton

  class StartInstruction < Instruction

    def initialize options = {}
      super 'start', options
    end

    def bt_execute scope, params
      scope.set :__RETVALS__, {}
    end

  end

end
