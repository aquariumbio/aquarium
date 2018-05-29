# frozen_string_literal: true

module Plankton

  class InformationInstruction < Instruction

    attr_reader :content

    def initialize(content, options = {})

      super 'information', options
      @content = content
      @renderable = true

    end

    # RAILS ###########################################################################################

    def pre_render(scope, _params)

      @content = scope.substitute @content
    rescue Exception => e
      raise 'Information error: Could not perform substitution on ' + @content + ': ' + e.message

    end

    def html
      '<b>information</b>'
    end

  end

end
