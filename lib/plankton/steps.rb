module Plankton

  class Parser

    def step
      
      description = ''
      note = ''
      warnings = []

      @tok.eat_a 'step'

      while @tok.current != 'end'

        case @tok.current

          when 'description'
            @tok.eat_a 'description'
            @tok.eat_a ':'
            description = @tok.eat_a_string.remove_quotes

          when 'note'
            @tok.eat_a 'note'
            @tok.eat_a ':'
            note = @tok.eat_a_string.remove_quotes

          when 'warning'
            @tok.eat_a 'warning'
            @tok.eat_a ':'
            warnings.push @tok.eat_a_string.remove_quotes

        end

      end

      @tok.eat_a 'end'

      puts "STEP: #{description}, #{note}, #{warnings}"

    end

  end

end
