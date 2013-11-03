module Plankton

  class Parser

    def step

      parts = []      
      description = ''
      note = ''
      warnings = []

      @tok.eat_a 'step'

      while @tok.current != 'end'

        case @tok.current

          when 'description'
            @tok.eat_a 'description'
            @tok.eat_a ':'
            parts.push({description: @tok.eat_a_string.remove_quotes})

          when 'note'
            @tok.eat_a 'note'
            @tok.eat_a ':'
            parts.push({note: @tok.eat_a_string.remove_quotes})

          when 'warning'
            @tok.eat_a 'warning'
            @tok.eat_a ':'
            parts.push({warning: @tok.eat_a_string.remove_quotes})

        end

      end

      @tok.eat_a 'end'

      push StepInstruction.new parts

    end

  end

end
