# frozen_string_literal: true

module Plankton

  class StopInstruction < Instruction

    def initialize(options = {})
      super 'stop', options
    end

    def stop
      true
    end

  end

end
